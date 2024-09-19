class ZCL_Z_JIRA_CHARM_INTEGRATION definition
  public
  final
  create public .

public section.

  methods CONSTRUCTOR .
  methods CREATE_NC
    importing
      !IS_ATTRIBUTES type ZJIRA_CHARM_STRU
    returning
      value(RS_ATTRIBUTES_RESP) type ZJIRA_CHARM_STRU .
  methods CREATE_DC
    importing
      !IS_ATTRIBUTES type ZJIRA_CHARM_STRU
    returning
      value(RS_ATTRIBUTES_RESP) type ZJIRA_CHARM_STRU .
protected section.
private section.
ENDCLASS.



CLASS ZCL_Z_JIRA_CHARM_INTEGRATION IMPLEMENTATION.


  method CONSTRUCTOR.
  endmethod.


  method CREATE_DC.
  endmethod.


  method CREATE_NC.
  endmethod.
ENDCLASS.
