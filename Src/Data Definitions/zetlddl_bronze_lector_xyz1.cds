@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Read data from zt_bronze_xyz_1 table'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZETLDDL_BRONZE_LECTOR_XYZ1
  as select from zt_bronze_xyz_1 as bronze
{
      key bronze.field1,
      key bronze.field2,
      bronze.field3,
      bronze.field4,
      bronze.field5
     
}
