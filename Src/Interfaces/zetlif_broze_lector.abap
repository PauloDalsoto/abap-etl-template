INTERFACE zetlif_bronze_lector
  PUBLIC.

  METHODS:
    read_data
      RETURNING
        VALUE(rt_data) TYPE REF TO DATA.

ENDINTERFACE.