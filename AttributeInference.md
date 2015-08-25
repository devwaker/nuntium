When a SMS message has to be delivered, it's often necessary to know the destination [country](API#Countries.md) and [carrier](API#Carriers.md). If the application knows any of these attributes it can specify them as custom attributes in the message. Otherwise, Nuntium will try to guess the destination country and carrier based on the mobile number.

First, it will use the country table to figure out which country is the message being sent to. Then, for some carriers, Nuntium can already know which prefixes corresponds to which carriers.

When a AT message arrives, the AT rules for a channel can also set these attributes. In that case, after these rules are executed, Nuntium will store the resulting country and carrier into the [mobile numbers table](MobileNumbersTable.md). This table will be used instead of this inferencing process for well known mobile numbers during the next AO message delivery.