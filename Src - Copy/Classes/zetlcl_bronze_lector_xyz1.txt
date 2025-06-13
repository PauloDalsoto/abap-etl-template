CLASS zetlcl_bronze_lector_xyz1 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES zetlif_bronze_lector
      ALL METHODS FINAL.

    ALIASES read_data
      FOR zetlif_bronze_lector~read_data.

    TYPES:
      BEGIN OF ty_s_bronze_xyz1,
        field1 TYPE zt_bronze_xyz_1-field1,
        field2 TYPE zt_bronze_xyz_1-field2,
        field3 TYPE zt_bronze_xyz_1-field3,
        field4 TYPE zt_bronze_xyz_1-field4,
        field5 TYPE zt_bronze_xyz_1-field5,

      END OF ty_s_bronze_xyz1,
      ty_t_bronze_xyz1 TYPE STANDARD TABLE OF ty_s_bronze_xyz1 WITH DEFAULT KEY.
      
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zetlcl_bronze_lector_xyz1 IMPLEMENTATION.

  METHOD zetlif_bronze_lector~read_data.
    SELECT
      field1,
      field2,
      field3,
      field4,
      field5
    FROM zetlddl_bronze_lector_xyz1
    INTO TABLE @DATA(lt_bronze).

    CREATE DATA rt_data TYPE ty_t_bronze_xyz1.
    ASSIGN rt_data->* TO FIELD-SYMBOL(<lt_data>).
    <lt_data> = lt_bronze.

  ENDMETHOD.
ENDCLASS.