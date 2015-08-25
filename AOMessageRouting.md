<img src='http://docs.google.com/drawings/pub?id=1zOQsLwDDNgqWlWVdIqTOC482AMV6ot93t7HJYvX1yfM&w=950&h=214&fmt=.png'>

These are the steps ran when a message is being delivered by an application through Nuntium:<br>
<br>
<ol><li>If the message is SMS:<br>
<ol><li>Save the <a href='API#Countries.md'>country</a> and <a href='API#Carriers.md'>carrier</a> <a href='Messages#Custom_attributes.md'>message attributes</a> to the <a href='MobileNumbersTable.md'>Mobile Numbers table</a>.<br>
</li><li>Run the <a href='AttributeInference.md'>attribute inference,</a> if "country" and/or "carrier" are still unknown.<br>
</li></ol></li><li>Run the <a href='Rules.md'>AO Rules</a> specified in the application that sent the message.<br>
</li><li><a href='Channels#Channel_Filter_Phase.md'>Filter</a> out the possible channels for delivering  the message.<br>
</li><li><a href='Channels#Channel_Selection_Strategy.md'>route</a> the message through any of the resulting channels.<br>
</li><li>Run the <a href='Rules.md'>AO Rules</a> specified in that resulting channel.