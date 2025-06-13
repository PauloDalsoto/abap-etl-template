CLASS zetlcl_to_silver_xyz2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zetlif_process_data ALL METHODS FINAL .

    " Tables name
    CONSTANTS:
      tbl_silver_xyz2 TYPE tabname26 VALUE 'ZT_SILVER_XYZ_2' ##NO_TEXT.

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
      ty_t_bronze_xyz2 TYPE zibpcl_stg_lector_fcst=>ty_t_fcst,
      ty_t_silver_xyz2 TYPE STANDARD TABLE OF zt_silver_xyz2 WITH DEFAULT KEY.

    METHODS:
      constructor
        IMPORTING
          !iv_lector_xyz2 TYPE REF TO zetlif_bronze_lector OPTIONAL,
      get_bronze_xyz2
        RETURNING
          VALUE(rt_data) TYPE ty_t_bronze_xyz2,
      get_silver_xyz2
        RETURNING
          VALUE(rt_data) TYPE ty_t_silver_xyz2.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: mo_lector_xyz2 TYPE REF TO zetlif_bronze_lector,
          bronze_xyz2    TYPE ty_t_bronze_xyz2,
          silver_xyz2     TYPE ty_t_silver_xyz2.

ENDCLASS.


CLASS zetlcl_to_silver_xyz2 IMPLEMENTATION.
  METHOD constructor.
    mo_lector_xyz2 =
      COND #( WHEN iv_lector_xyz2 IS NOT BOUND
                THEN NEW zetlcl_bronze_lector_xyz2( )
              ELSE iv_lector_xyz2
             ).

  ENDMETHOD.

  METHOD zetlif_process_data~clear_target_table.
    DELETE FROM (tbl_silver_xyz2).

  ENDMETHOD.

  METHOD zetlif_process_data~read_source_data.
    DATA lt_data   TYPE REF TO data.
    FIELD-SYMBOLS <lt_bronze> TYPE STANDARD TABLE.

    tl_fcst_data = mo_lector_xyz2->read_data( ).
    ASSIGN lt_data->* TO <lt_bronze>.

    me->bronze_xyz2 = <lt_bronze>.

  ENDMETHOD.

  METHOD zetlif_process_data~save_data.
    IF silver_xyz2 IS NOT INITIAL.
      INSERT (tbl_silver_xyz2) FROM TABLE me->silver_xyz2.
    ENDIF.

  ENDMETHOD.

  METHOD zetlif_process_data~transform_data.
    DATA: ls_silver_xyz2  LIKE LINE OF silver_xyz2.
    
    LOOP AT me->bronze_xyz2 ASSIGNING FIELD-SYMBOL(<ls_bronze>).
     MOVE-CORRESPONDING <ls_bronze> TO ls_silver_xyz2.

      " Apply any transformations needed here

      APPEND ls_silver_xyz2 TO me->silver_xyz2.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_silver_xyz2.
    rt_data = me->silver_xyz2.

  ENDMETHOD.

  METHOD get_bronze_xyz2.
    rt_data = me->bronze_xyz2.

  ENDMETHOD.
ENDCLASS.