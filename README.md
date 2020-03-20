Version 1.0.19
Added a black list to text fields for ' & "
Changed Fields to have cap first letter
Collection 'Type an ID' field checks black list
Changed add collect to have caps for all words
Search field on selector screen checks blacklist, starts with a cap
Search field when you hit the plus button it will tell you to search first
Fields for upload pages now check the blacklist,
Change user admin window from 'Hide Collector ID' to 'Barcode Only'


Version 1.0.18
locked down the os back button

Version 1.0.17
Incremented for appstore, all other builds have been sending the debug ptrace file?


Version 1.0.16
Admin now has a spinner so you can see if you have saved it

Version 1.0.15
? increment for upload to apple?

Version 1.0.14
? increment for upload to apple?


Version 1.0.13
Deleting a voucher/note from a sample reappears when you come back into the species list screen. Fixed

Version 1.0.12
Tried uploading to Appstore again failed! Need to increment each time!


Version 1.0.11
Add spinners to admin pages and give feed back if successfully saved to the server



Version 1.0.10
- stop the android system back button from working and causing the app to lose data
- remove 'Individual' counter number from the Sample and Voucher icons on the collection list


Version 1.0.9
- Show time on os status bar for the Collection detail screen (which is also the sight not sighted screen) so the user can compare with the gps date
- change the export column title from "Incidental observation" to "Record type"
- slider switches on the user settings screen don't move when tapped but they are actually triggered and when you close and come back into the settings screen they have actually moved, this has been fixed
- exported voucher barcode flows through to everything after it, fixed
- gps updates to worse ?, couldn't recreate, cleaned up the code a bit


Version 1.0.8
-android version wasn't compiled with the send of emails correctly,
-ios was, recompiled for playstore and updated online


Version 1.07
- A species adding to the collecting list can now have it's name changed by entering the population form and tapping on the species name at the top of the screen, this
lets the user select a new species from the list or type a new name
-- collection types are now generic so they can reuse the same code and add more types easily
-- added in a new database table for 'Individual' so the database is now
    A 'Population' can have many 'Individual's, each 'Individual' can have many 'Collections', 'Collections' can be of type, 'Sample', 'Voucher', 'Sighted', 'Not Sighted' 'Note', and many other types can now be added. 
- a 'Collection' type was added for seed, this was turned off because the gardens database can't accept the record type, A 'Collection' type of 'Note' can be used as a sub
- update the status under a species to now show a seed collection count
- A 'Collection' type of Notes is now available for an 'Individual'.
- if the an Individual has one 'Collection' of the type 'Note' that note is exported as a population 'Note' else it is exported as a note for that individual.
- Now have an option to remove after uploading in the user settings



TODO

-- make it so you can add all the other types to the current type... i.e. seed can have a sample and voucher etc...
- add note from collection type list, just adds a flag and gives it a different icon...
- flags, make them open then get gps, and show a spinner
- CHANGE SEED COLLECTION TO HAVE A BEIGE PACKET
- allow users to add new var / subsp from a picker set up, i.e. fill out the genus, species, subtype, then subname, uses could pick each from a list or add new... not sure how to do this yet
- add capitals to any text fields you type in
- upload dialog show the count of sites ready to upload?
- delete sites once uploaded, can't be sure that they have been sent...

####################################################################


Version 1.06


- Now sends an email to the logged in user and an email to the RnR server.
- now have a user manual

TODO
- upload dialog show the count of sites ready to upload?
- delete sites once uploaded, can't be sure that they have been sent...




####################################################################

Version 1.05
-added a log in as public or private user page
-now has 'public' and 'private' log in screens
- added inital (first only for public user), the code was in a constructor that I could get so just did 1 letter
-added back buttons on the public and private log in windows
-if collect is public don't show rnr collector names when you click on the icon for the collector
-if collect is public don't show the rnr collector list when they click the plus icon for a new collector
- now need to have a 'precise location' in a site before you can fill out the rest of the form
- added new user preferences for hiding the collector id and the site gps
- form hides until you fill out the precise location
- now shows the version number on the user prefs window, it's manually entered in the site list page 



TODO
- upload dialog show the count of sites ready to upload?
- on export check if the user has a password and send data to rnr (need an address from work)
- delete sites once uploaded, can't be sure that they have been sent...


BUG 
edit user screen crashes!!! fixed, changed the pop to happen inside the function that does the push


####################################################################
Version 1.04

CHANGES
- has the start of website intergration... on hold










    

# RnR-Flutter-Mobile-App
