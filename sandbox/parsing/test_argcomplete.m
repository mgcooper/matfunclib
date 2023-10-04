{
   "_schemaVersion": "1.0.0",
   "barchartcats":
   {
      "inputs":
      [
         {"name":"T",         "kind":"required",   "type":["tabular"]},
         {"name":"ydatavar",  "kind":"positional", "type":[["char","choices=T.Properties.VariableNames","scalar"], ["string","choices=T.Properties.VariableNames","scalar"]], "purpose":"Option"},
         {"name":"xgroupvar", "kind":"positional", "type":[["char","choices=T.Properties.VariableNames","scalar"], ["string","choices=T.Properties.VariableNames","scalar"]], "purpose":"Option"},
         {"name":"cgroupvar", "kind":"positional", "type":[["char","choices=T.Properties.VariableNames","scalar"], ["string","choices=T.Properties.VariableNames","scalar"]], "purpose":"Option"}
      ]
   }
}
   