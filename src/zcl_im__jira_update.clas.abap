class ZCL_IM__JIRA_UPDATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_ORDER_SAVE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM__JIRA_UPDATE IMPLEMENTATION.


  method if_ex_order_save~change_before_update.
    data lv_jira_guid type crmt_po_number_sold.
    data lv_msg type symsg.

    call method zcl_z_jira_charm_integration=>get_jira_id
      exporting
        iv_guid    = iv_guid
      importing
        ev_jira_id = lv_jira_guid.

    if lv_jira_guid is not initial.
      call method zcl_z_jira_charm_integration=>set_jira_fields
        exporting
          iv_guid          = iv_guid
        importing
          es_error_message = lv_msg.
    endif.

  endmethod.


  method IF_EX_ORDER_SAVE~CHECK_BEFORE_SAVE.
  endmethod.


  method IF_EX_ORDER_SAVE~PREPARE.
  endmethod.
ENDCLASS.
