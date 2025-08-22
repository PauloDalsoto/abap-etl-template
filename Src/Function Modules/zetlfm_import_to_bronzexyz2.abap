FUNCTION zetlfm_import_to_bronzexyz2.
  TABLES
    it_input_data LIKE ztt_xyz
    rt_return LIKE bapiret2 OPTIONAL.

  DATA: 
    lv_return      TYPE bapi_mtype,
    lt_data_ref    TYPE REF TO data,
    lv_table_name  TYPE tabname16.
       
  IF lines( it_input_data[] ) GE 1.
    lv_table = zcl_etl_process_handler=>tbl_target_xyz_2.    
  ELSE.
        RETURN.
  ENDIF.

  CREATE DATA lt_table_ref TYPE TABLE OF (lv_table).
  ASSIGN lt_table_ref->* TO FIELD-SYMBOL(<lt_data>).
  <lt_data> = it_input_data[].

  CALL METHOD zcl_etl_process_handler=>load_and_process_data
    EXPORTING
      iv_table       = lv_table
      it_data        = lt_table_ref
    RECEIVING
      ev_return      = lv_ret.
  
ENDFUNCTION.
