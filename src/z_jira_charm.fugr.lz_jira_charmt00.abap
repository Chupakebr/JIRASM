*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZJIRA_MAPPING...................................*
DATA:  BEGIN OF STATUS_ZJIRA_MAPPING                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZJIRA_MAPPING                 .
CONTROLS: TCTRL_ZJIRA_MAPPING
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZJIRA_MAPPING                 .
TABLES: ZJIRA_MAPPING                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
