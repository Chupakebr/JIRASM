class ZL_AIC_CMCD_AICCMCDHEADER_IMPL definition
  public
  inheriting from CL_AIC_CMCD_AICCMCDHEADER_IMPL
  create public .

public section.
protected section.

  data ZTYPED_CONTEXT type ref to ZL_AIC_CMCD_AICCMCDHEADER_CTXT .

  methods DO_HANDLE_EVENT
    redefinition .
  methods SET_MODELS
    redefinition .
  methods WD_CREATE_CONTEXT
    redefinition .
private section.
ENDCLASS.



CLASS ZL_AIC_CMCD_AICCMCDHEADER_IMPL IMPLEMENTATION.


  method DO_HANDLE_EVENT.

* Eventhandler dispatching
    CASE htmlb_event_ex->event_server_name.
      WHEN OTHERS.

        global_event = super->do_handle_event( event           = event
                                               htmlb_event     = htmlb_event
                                               htmlb_event_ex  = htmlb_event_ex
                                               global_messages = global_messages ).

    ENDCASE.


  endmethod.


  method SET_MODELS.


    super->set_models( view ).


  endmethod.


  method WD_CREATE_CONTEXT.
*   create the context
    context = cl_bsp_wd_context=>get_instance(
            iv_controller = me
            iv_type = 'ZL_AIC_CMCD_AICCMCDHEADER_CTXT' ).

    typed_context ?= context.
    styped_context ?= context.

* Added by wizard
   ztyped_context ?= context.
  endmethod.
ENDCLASS.
