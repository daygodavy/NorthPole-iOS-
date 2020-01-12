# Homework4-F19

Daniel Weatrowski,
Davy Chuon,
Viviana Rosas Romero,
Yashodhan Kulkarni


# Sprint Planning 1

## Project Summary:

For our app, we will be making a Christmas (or more generally gift tracking) app that will aid users' experience for their holiday shopping. Users will be able to list gifts they plan on buying and can mark them off as they are bought (like a grocery list for gifts). The gifts they purchase will then record information specifying the item, price,  intended recipient for the gift, and accumulated data for money spent overall. Aside from the main premise, we are also potentially adding other features for users such as gift exchanging that would resemble a Secret Santa generator, a countdown until Christmas, and more.

## Tasks:

* Daniel Weatrowsky - "I will work with the UI of the app and build a responsive design with interface builder and autolayout"

* Davy Chuon - "I will work on implementing the backend for our initial views (home screen) to establish the base of our app functionality"

* Viviana Romero - "I will help figuring out how to use firebase and what functionality we will most likely need for the app"

* Yashodhan Kulkarni - "I will work on the backend including linking the UI items to swift code and interacting with the firebase database."






# Sprint Planning 2

## Project Summary:

We added Login/SignUp UI and SignInViewController. This uses Firebase to upload information to a database. I know we mentioned we wanted to use CoreData instead of Firebase, but I think having user functionality is useful if different users will interact with each other in the future (secret santa functionality). Additionally, if we plan to track our app usage, Firebase has google analytics user tracking that we can view on the dashboard. Combined Yash's code with the coredata and UI update. Yash also worked on a countdown that will be displayed that shows how many days are remaining till christmas. Daniel worked on the storyboard UI and View Controllers. This is our basic layout of the budget aspect of our app. 


## Tasks:

* Daniel Weatrowsky - "I will work on the view controllers, creating countdown view and finishing the home view. I will also clean up the logo if it needs to be changed."

* Davy Chuon - "I will work on the backend by connecting views and implementing the general flow that users will experience while using the app by using sample data to incorporate the functionality for now." https://github.com/ECS189E/project-f19-icy/tree/DavyBranch

* Viviana Romero - "I will work on the structure of the firebase database and what data points we need for the app."

* Yashodhan Kulkarni - "I will help saving data to firebase database and using it in the functionality. I also want to help with the view controllers and getting a basic functionality going."





## Team (name - Github)

### Daniel Weatrowski - @danielweatrowski

<img src="img/dan.jpg" width="350" height="400" alt="dan" />

### Davy Chuon - @daygodavy

<img src="img/davy.jpg" width="350" height="400" alt="davy" />

### Yashodhan Kulkarni - @ ypkulkar

<img src="img/yash.png" width="350" height="400" alt="yash"  />

### Viviana Rosas Romero - @varelycode

<img src="img/viv.png" width="350" height="400" alt="viv"  />

## Trello
https://trello.com/b/HHd9J0U0/north-pole




# Sprint Planning 3

## Project Summary:

For our app, we will be making a Christmas (or more generally gift tracking) app that will aid users' experience for their holiday shopping. Users will be able to list gifts they plan on buying and can mark them off as they are bought (like a grocery list for gifts). The gifts they purchase will then record information specifying the item, price, intended recipient for the gift, and accumulated data for money spent overall. Aside from the main premise, we are also adding other features for users such as gift exchanging that would resemble a Secret Santa generator, a countdown until Christmas, Google OCR recognition for Amazon receipts, and a wishlist.



## Sprint 2 Progress:

- Daniel Weatrowski - I finished home view, settings view and added a view for user wishlist. Currently still debugging some UI elements. Settings view is almost complete. 
- Davy Chuon - "I have created the models for giftees, gifts, and wishlist. I have implemented the backend for the giftee view and giftee details view with Firebase integration to save relevant information/data. I have implemented the prototype backend for wishlist and will integrate with Firebase."
  - https://github.com/ECS189E/project-f19-icy/commits/DavyGiftsViewBackend
  - https://github.com/ECS189E/project-f19-icy/commits/DavyBranch
  - https://github.com/ECS189E/project-f19-icy/commits/DavyWishListBackend
- Viviana Romero - Yash and I worked on the OCR. We were able to connect the MLKit from Firebase and integrated it with a seperate application. We were able to process the information from Amazon reciepts grabbing the price and name of the image submitted. 
- Yashodhan Kulkarni - As Viviana said, we worked on the OCR API. We were able to get the cost and the name of the product from the image of the receipt. 



## Sprint 3 Tasks:

- Daniel Weatrowski - "I will work on the view controllers, finishing the home view and settings view and wishlist view. I also plan to completely delete the countdown view as it is now integrated in the home. I will also clean up the logo if it needs to be changed."
- Davy Chuon - "I will work on finishing the backend and firebase connection for all the current views produced and integrating the secret santa functionality between users. I will also look into potential APIs that could be used for our interactive secret santa." 
- Viviana Romero - "I will work on the view controllers for the secret santa feature and allowing users to add friends to their secret santa group. I will also work on the registration to add more fields upon registration. Implementing the OCR we worked on to the main project will be another thing I will work on."
- Yashodhan Kulkarni - "I will work on integrating the OCR API with out actual project. I will help Viviana with backend that involves the users having a friend list. I also want to work on getting the OCR parsing better and more efficient."

# Sprint Planning 4

## Project Summary:
For our app, we will be making a Christmas (or more generally gift tracking) app that will aid users' experience for their holiday shopping. Users will be able to list gifts they plan on buying and can mark them off as they are bought (like a grocery list for gifts). The gifts they purchase will then record information specifying the item, price, intended recipient for the gift, and accumulated data for money spent overall. Aside from the main premise, we are also adding other features for users such as gift exchanging that would resemble a Secret Santa generator, a countdown until Christmas, Google OCR recognition for Amazon receipts, and a wishlist.



## Sprint 3 Progress:
- Daniel Weatrowski - Added a new view controller for adding wishlist items. Cleaned up the giftee view and giftee detail view. Helped with delete functionality.
- Davy Chuon - I have completed the backend for the wishlist view with Firebase integration. I have added delete functionality in the giftee, gift and wishlist views with Firebase integration. I have been designing the app icon/logo and splash screen. I have been researching the best way for users to view each other's wishlist.
  - https://github.com/ECS189E/project-f19-icy/tree/DavyWishlistBackend
- Viviana Romero - Worked with Yash in integrating OCR 
- Yashodhan Kulkarni - I worked with Viviana in integrating the OCR with the app and it works now. I also fixed errors and bugs and worked on home view functionality.



## Sprint 4 Tasks:
- Daniel Weatrowski - Finish settings view controller, and settings view controller. Help with any other UI elements that need to be added along the way.
- Davy Chuon - I will be working on adding more error and edge case handling on the backend side, I will  work on refining the backend code, improving the UX, implementing backend for views after the frontend is finalized, and incorporating wishlist interaction between users.
- Viviana Romero - Worked on OCR functionality and the wishlist controllers. Implemented delete
- Yashodhan Kulkarni - If decided, Viviana and I will be working on making OCR compatible with Target and Walmart receipts. I will also help with settings view controller. I will also help my teammates if needed. 



### Trello 

- https://trello.com/b/HHd9J0U0/north-pole





# Sprint Planning 5

## Project Summary:
For our app, we will be making a Christmas (or more generally gift tracking) app that will aid users' experience for their holiday shopping. Users will be able to list gifts they plan on buying and can mark them off as they are bought (like a grocery list for gifts). The gifts they purchase will then record information specifying the item, price, intended recipient for the gift, and accumulated data for money spent overall. Aside from the main premise, we are also adding the following features: a countdown until Christmas, Google OCR recognition for Amazon receipts, and user wishlist.



## Sprint 4 Progress:
- Daniel Weatrowski - Finished settingsview, added a view for adding wishlist items. Removed minor bugs and cleaned up autolayout issues.

- Davy Chuon - I have fixed subtle bugs in various views, added some UI checks and error handling where necessary (i.e. catching and prompting user of invalid input), simplified dismissing keyboard whenever used by user, helped Yash with implementing resetting user's data in app, implemented auto login, implemented view for and ability for users to view other users' wishlists, and began implementation for user followings view.
  - https://github.com/ECS189E/project-f19-icy/tree/DavyAutoLogin
  - https://github.com/ECS189E/project-f19-icy/tree/resetdata
  - https://github.com/ECS189E/project-f19-icy/tree/DavyFriendslist
  
- Viviana Romero - Worked on implementing wishList functionality. This includes ensuring a user can succesfully add and delete from the database. I also connected an add item view to the table view with protocols and delegates. Also worked on fixing some bugs and redesigning the login view. 

- Yashodhan Kulkarni - 



## Sprint 5 Tasks:
- Daniel Weatrowski - Finish login views, add app icons and launch screen icon. Deploy to appstore.

- Davy Chuon - Cleaning up backend for most views, following standards of App store requirements (i.e. adding activity indicators), finishing backend with firebase integration for user followings view and other users wishlist views, and potentially implementing image storage for wishlist items.

- Viviana Romero - Helping Davy work on the friends list and adding OCR functionlaity for walmart and other reciepts. 

- Yashodhan Kulkarni - Cleaning up settings view controller, adding user authentication for reset data. Cleaning up the OCR functionality and helping team mates if needed. 

## Final Comments
- Daniel Weatrowski - My primary job throughout the project was the construction of the UI. Each view was crafted via sketch before hand and then constructed on the storyboard itself. I also aided in the implementation of the WishlistViewController, specifically the share sheet and link buttons on the cells that contained a link. Other than that, I helped by building the app icon and implementing other UI features such as the search bar or empty tableview scenes. 
- Viv Final Comments: I was involved with creating the Login/Sign Up view and developing the wishlist and add wishlist view controllers. I also helped with the Home view controller to display the items. I also helped debug some problems with add reciepients view controllers , add giftees, and OCR. I tried to make myself as flexible as possible when it comes to what I worked on. The most difficult thing for me was learning how to resolve conflicts 

- Yashodhan Kulkarni - I worked on the settings view controller, home view controller and helped with the wishlist and searching functionality. I implemented the countdown and worked on the Google OCR API. I got better with git and merging conflicts. This project helped my teamwork skills.

- Davy Chuon - I implemented the backend and firebase database integration for the RecipientsViewController and RecipientsDetailViewController. I integrated firebase database and backend for the custom alerts (Alert manager) that prompted users for input. I implemented the backend and firebase database integration for the OtherUserWishlistViewController & UserFollowingsViewController (4th tab bar: which allows users to view other users’ wishlists, follow other users’ wishlists and stores the users’ wishlists they follow into a tableview). I helped Yash with some firebase integration with the SettingsViewController. I integrated the auto-login (in scene delegate). I helped with the prototype implementation for the wishlistviewcontroller. I created the Giftee, User, and userFollowed models.

### For demoing "My Wishees" Tab:
In this view (accessed by pressing the fourth tab in the tab bar), the user is able to search for other users via phone number (by pressing the red add button in the top right) to view their wishlist and potentially save their wishlist to save it in the tableview of "My Wishees". Thus, below are provided phone numbers in the database in order to successfully find an existing users wishlist for viewing and/or saved:
- 5302017701
- 6192017701
- 9162017701
- 7147824460
- 9162842475

Once viewing another user's wishlist, you can save/unsave their wishlist by pressing the "heart" button in the top right.


### Trello 

- https://trello.com/b/HHd9J0U0/north-pole
