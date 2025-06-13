REPORT zetlre_bronze_to_silver.

DATA: lo_orchestrator TYPE REF TO zetlcl_to_silver_orchestrator.
CREATE OBJECT lo_orchestrator.

lo_orchestrator->run_tagging_process( ).