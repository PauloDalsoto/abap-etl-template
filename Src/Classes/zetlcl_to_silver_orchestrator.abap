CLASS zetlcl_to_silver_orchestrator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS:
      constructor
        IMPORTING
          !iv_to_silver_xyz1 TYPE REF TO zetlif_process_data OPTIONAL
          !iv_to_silver_xyz2 TYPE REF TO zetlif_process_data OPTIONAL,
      run_tagging_process.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: 
      mo_to_silver_xyz1       TYPE REF TO zetlif_process_data,
      mo_to_silver_xyz2       TYPE REF TO zetlif_process_data.

    METHODS:
      process_single
        IMPORTING
          iv_processor       TYPE REF TO zetlif_process_data.

ENDCLASS.


CLASS zetlcl_to_silver_orchestrator IMPLEMENTATION.

  METHOD constructor.
    mo_to_silver_xyz1 =
      COND #( WHEN iv_to_silver_xyz1 IS NOT BOUND
                THEN NEW zetlcl_to_silver_xyz1( )
              ELSE iv_to_silver_xyz1
              ).

    mo_to_silver_xyz2 =
      COND #( WHEN iv_to_silver_xyz2 IS NOT BOUND
                THEN NEW zetlcl_to_silver_xyz2( )
              ELSE iv_to_silver_xyz2
             ).

  ENDMETHOD.

  METHOD run_tagging_process.
    process_single( mo_to_silver_xyz1 ).
    process_single( mo_to_silver_xyz2 ).

    COMMIT WORK.

  ENDMETHOD.

  METHOD process_single.
    iv_processor->read_source_data( ).
    iv_processor->transform_data( ).
    iv_processor->clear_target_table( ).
    iv_processor->save_data( ).

  ENDMETHOD.
ENDCLASS.