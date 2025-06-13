CLASS zetlcl_to_silver_xyz1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zetlif_process_data ALL METHODS FINAL .

    " Tables name
    CONSTANTS:
      tbl_silver_xyz1 TYPE tabname16 VALUE 'ZT_SILVER_XYZ_1' ##NO_TEXT.

    ALIASES:
      clear_target_table
        FOR zetlif_process_data~clear_target_table,
      read_source_data
        FOR zetlif_process_data~read_source_data,
      transform_data
        FOR zetlif_process_data~transform_data,
      save_data
          FOR zetlif_process_data~save_data.
    
    TYPES:
      ty_t_bronze_xyz1 TYPE zibpcl_stg_lector_fcst=>ty_t_fcst,
      ty_t_silver_xyz1 TYPE STANDARD TABLE OF zt_silver_xyz1 WITH DEFAULT KEY.

    METHODS:
      constructor
        IMPORTING
          !iv_lector_xyz1 TYPE REF TO zetlif_bronze_lector OPTIONAL,
      get_bronze_xyz1
        RETURNING
          VALUE(rt_data) TYPE ty_t_bronze_xyz1,
      get_silver_xyz1
        RETURNING
          VALUE(rt_data) TYPE ty_t_silver_xyz1.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mo_lector_xyz1 TYPE REF TO zetlif_bronze_lector,
          bronze_xyz1    TYPE ty_t_bronze_xyz1,
          silver_xyz1     TYPE ty_t_silver_xyz1.

ENDCLASS.


CLASS zetlcl_to_silver_xyz1 IMPLEMENTATION.
  METHOD constructor.
    mo_lector_xyz1 =
      COND #( WHEN iv_lector_xyz1 IS NOT BOUND
                THEN NEW zetlcl_bronze_lector_xyz1( )
              ELSE iv_lector_xyz1
             ).

  ENDMETHOD.

  METHOD zetlif_process_data~clear_target_table.
    DELETE FROM (tbl_silver_xyz1).

  ENDMETHOD.

  METHOD zetlif_process_data~read_source_data.
    DATA lt_data   TYPE REF TO data.
    FIELD-SYMBOLS <lt_bronze> TYPE STANDARD TABLE.

    tl_fcst_data = mo_lector_xyz1->read_data( ).
    ASSIGN lt_data->* TO <lt_bronze>.

    me->bronze_xyz1 = <lt_bronze>.

  ENDMETHOD.

  METHOD zetlif_process_data~save_data.
    IF silver_xyz1 IS NOT INITIAL.
      INSERT (tbl_silver_xyz1) FROM TABLE me->silver_xyz1.
    ENDIF.

  ENDMETHOD.

  METHOD zetlif_process_data~transform_data.
    DATA: ls_silver_xyz1  LIKE LINE OF silver_xyz1.
    
    LOOP AT me->bronze_xyz1 ASSIGNING FIELD-SYMBOL(<ls_bronze>).
     MOVE-CORRESPONDING <ls_bronze> TO ls_silver_xyz1.

      " Apply any transformations needed here

      APPEND ls_silver_xyz1 TO me->silver_xyz1.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_silver_xyz1.
    rt_data = me->silver_xyz1.

  ENDMETHOD.

  METHOD get_bronze_xyz1.
    rt_data = me->bronze_xyz1.

  ENDMETHOD.
ENDCLASS.