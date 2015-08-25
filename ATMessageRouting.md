<img src='http://docs.google.com/drawings/pub?id=1W42K2Bs_f-DVX79I2KjYJE86FtgqdvfINMyUdF6TdMs&w=950&h=214&f=.png'>

These steps are ran when a message arrives to Nuntium through an inbound channel:<br>
<br>
<ol><li>Execute the <a href='Rules.md'>AT rules</a> specified for the incoming channel.<br>
</li><li>If the message is SMS, save "country" and/or "carrier" if these attributes were specified by any of the previous rules.<br>
</li><li>Run the attribute inference if "country" and/or "carrier" are still unknown.<br>
</li><li>Run the <a href='Rules.md'>application routing rules</a>, unless the rules in the first point has set the "application" attribute. <b>This step is not run if the account has only one application.</b>
</li><li>Save the incoming channel in the address source table for the target application.