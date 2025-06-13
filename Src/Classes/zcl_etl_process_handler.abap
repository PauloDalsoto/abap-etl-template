CLASS zcl_etl_process_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    " Status constants
    CONSTANTS: c_jobname TYPE char30     VALUE 'ZETL_PROCESS_JOB',
               c_report  TYPE progname   VALUE 'ZETL_PROCESS_REPORT',
               c_success TYPE bapi_mtype VALUE 'S',
               c_error   TYPE bapi_mtype VALUE 'E',
    
    " Tables name
               tbl_target_xyz_1 TYPE tabname16 VALUE 'ZT_BRONZE_XYZ_1' ##NO_TEXT,
               tbl_target_xyz_2 TYPE tabname16 VALUE 'ZT_BRONZE_XYZ_2' ##NO_TEXT.

    " Generic ETL operations
    CLASS-METHODS:
      check_table_is_valid
        IMPORTING iv_table TYPE tabname16
        RETURNING VALUE(ev_return) TYPE bapi_mtype,

      clear_target_table
        IMPORTING iv_table TYPE tabname16
        RETURNING VALUE(ev_return) TYPE bapi_mtype,

      load_data_to_target_table
        IMPORTING iv_table TYPE tabname16
                  it_data  TYPE data
        RETURNING VALUE(ev_return) TYPE bapi_mtype,

      schedule_background_job
        IMPORTING
          iv_jobname       TYPE char30
          iv_report        TYPE progname
        RETURNING VALUE(ev_return) TYPE bapi_mtype,

      load_and_process_data
        IMPORTING
          iv_table         TYPE tabname16
          it_data          TYPE data
        RETURNING VALUE(ev_return) TYPE bapi_mtype.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcl_etl_process_handler IMPLEMENTATION.

  METHOD check_table_is_valid.
    IF  iv_table <> tbl_target_xyz_1
    AND iv_table <> tbl_target_xyz_2.
      ev_return = c_error.
    ELSE.
      ev_return = c_success.
    ENDIF.

  ENDMETHOD.

  METHOD clear_target_table.
    IF zcl_etl_process_handler=>check_table_is_valid( iv_table ) = c_error.
      ev_return = c_error.
      RETURN.
    ENDIF.

    DELETE FROM (iv_table).
    COMMIT WORK AND WAIT.

    ev_return = c_success.

  ENDMETHOD.

  METHOD load_data_to_target_table.
    FIELD-SYMBOLS: <lt_insert> TYPE STANDARD TABLE.

    IF zcl_etl_process_handler=>check_table_is_valid( iv_table ) = c_error.
      ev_return = c_error.
      RETURN.
    ENDIF.

    ASSIGN it_data->* TO <lt_insert>.
    IF <lt_insert> IS NOT ASSIGNED.
      ev_return = c_error.
      RETURN.
    ENDIF.

    INSERT (iv_table) FROM TABLE <lt_insert>.
    IF sy-subrc IS INITIAL.
      COMMIT WORK AND WAIT.
    ELSE.
      ev_return = c_error.
      ROLLBACK WORK.
      RETURN.
    ENDIF.

    ev_return = c_success.

  ENDMETHOD.

  METHOD schedule_background_job.
    DATA lv_jobcount TYPE tbtcjob-jobcount.

    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname  = iv_jobname
      IMPORTING
        jobcount = lv_jobcount
      EXCEPTIONS
        OTHERS   = 1.

    IF sy-subrc <> 0.
      ev_return = c_error.
      RETURN.
    ENDIF.
 
    CALL FUNCTION 'JOB_SUBMIT'
      EXPORTING
        jobname   = iv_jobname
        authcknam = sy-uname
        jobcount  = lv_jobcount
        report    = iv_report
      EXCEPTIONS
        OTHERS    = 1.

    IF sy-subrc <> 0.
      ev_return = c_error.
      RETURN.
    ENDIF.

    CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobname   = iv_jobname
        jobcount  = lv_jobcount
        strtimmed = abap_true
      EXCEPTIONS
        OTHERS    = 1.
        
    IF sy-subrc <> 0.
      ev_return = c_error.
      RETURN.
    ENDIF.

    ev_return = zibpcl_extracion_tablas_ibp=>c_success.

  ENDMETHOD.

  METHOD load_and_process_data.
    " Clean up the target table before loading new data
    CALL METHOD zcl_etl_process_handler=>clear_target_table
      EXPORTING
        iv_table  = iv_table
      RECEIVING
        ev_return = ev_return.

    IF ev_return <> zcl_etl_process_handler=>c_success.
      RETURN.
    ENDIF
    
    " Load data into the target table
    CALL METHOD zcl_etl_process_handler=>load_data_to_target_table
      EXPORTING
        iv_table  = iv_table
        it_data   = it_data
      RECEIVING
        ev_return = ev_return.
    
    IF ev_return <> zcl_etl_process_handler=>c_success.
      RETURN.
    ENDIF.
    
    " Start a background job to process the data
    CALL METHOD zcl_etl_process_handler=>schedule_background_job
      EXPORTING
        iv_jobname = c_jobname
        iv_report  = c_report
      RECEIVING
        ev_return  = ev_return.

    IF ev_return <> zcl_etl_process_handler=>c_success.
      RETURN.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
