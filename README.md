# flutter_blog_post_project
IT15 – INTEGRATIVE PROGRAMMING AND TECHNOLOGIES

Final Project

Blog Post and Messaging with Firebase Cloud Firestore – Chat Services
Mobile application

Members:
Andy R. Abanto Jr.
Bostjan Zymmer Rogero
Jan Wayne Sepe

MarkDown file.
March 2024

**
Objective: Create a secure and efficient messenger app tailored for a specific firm, which includes integration with a public API or service from the internet.


This app utilizes Flutter framework to create blog posts, and real-time messaging. Also added weather update API.
This app heavily relies in Firebase services. A strong internet connection is required.
Weather API will change themes according to various weather conditions. Temperature changes rapidly

Registered users can create blog posts. Users must have an image, a title, and the description to post.
Users can edit their post content.
Users can delete their post.
Users can interact with each other by leaving a like on one of the posts, or to leave a comment.
Text messaging ang chats are utilized with Google Firebase Database - Chat Services.
Security is within Google Firebase Database for storing blog posts, images, users, and messages.
Theme is in orange by default, the theme color can be changed when enabling dark mode on the phone’ setting.
Text messaging can also upload photos in chats.
Text messaging chats including group chats has a text to speech plugin. Tap on every message to speak the message for you.
Text to speech does not work on photos sent on every user.  
Creating group chats is possible, group chat creator automatically assigned as admin. Add registered users in your group chat.
Weather API is integrated into the app for weather updates in the city [Davao city].

Features checklist:
User Authentication and Authorization: Handled by Firebase Authentication
Real-time messaging: Handled by Firebase Cloud Firestore - Chat services
Group chats: Able to create and manage group chats
Integration with External API:
Internal: Utilizing Firebase services for fetching, and management of data.
External: Open Weather API [openweathermap.org]
Notifications: Triggered within the app itself in both chats. No real-time push notifications integrated in the app but only local notifications.
Search functionality: Users can search for registered users for messaging.
Profile management: Handled by Firebase Realtime Database, users can change their profile picture, their bio, and their username but not their email address.
Security: All are handled by Firebase services. Passwords only accept 6-15 characters.
User experience: Default theme can only be changed by the user's device by enabling global dark mode. For older android devices where some do not have a dark mode feature, only displays with the default orange theme.
Page theme for weather updates changes in varied weather conditions.
Weather temperature updates rapidly every minute.
Theme colors exclusively apply to this page, and not on the whole application’s interface. (This also applies to devices with dark mode.)

Plugins used:
Flutter text to speech
Flutter local notifications

APIs used:
OpenWeather API

Databases used:
Firebase Realtime Database

Crucial messaging services used in this project:
Firebase Cloud Firestore - Chat Services
Firebase Authentication
And other Firebase Services.

**



User manual:



Login page:
Upon launching the application, you will be directed to the login page.
If you do not have an account, just tap the link:” Register here!”

Registration page:
To create your account, enter the necessary fields.
Entering your username will serve as your username within the app.
Entering your email serves as the required email for you to log in to this app.
Enter your password to gain access to this app. Passwords must be more than 6 to 15 characters.
If all required fields are entered. Tap on the “REGISTER” button to proceed to the login page.

Blog Posting Interface:
Tap on the hamburger icon on the top left section of the AppBar.
This will show 3 menus. Tap “Home” to proceed to the blogs view. By default, upon logging in, this section shows up.
To leave a like on a post, tap the “❤” button. This will leave a like on that post.
Tap it again to “unlike” that post.
To comment, tap on the “💬” button.
Type your comment then press the send button.

‘This will instantly post your comment.

To delete your comment, tap on the “🗑️” button. A confirmation message appears. Tap on “Continue” to delete your comment. Otherwise, tap on “Cancel”.

User profile:
Tap on any other user on their post to show their profile page.
This is their user information. In the next chapter, you will learn how to customize your user information.
This shows their profile image, their email, their username, and their bio.
Other users cannot change values on different user accounts. Just themselves.
You can message other people by tapping the “✉︎” button.
This will direct you to your conversation between this user.

User profile page:
In the hamburger icon, tap on “Your Profile” and this will direct you to this page.
Here, you will see your username, your empty profile picture, and your bio.
To upload your profile image, tap on “Upload profile image.”
Tap on “Pick File” to select your desired image. Then tap on “Submit”.
This will set your image as your profile photo.

To change your username, tap on the edit button.
This will show you a dialog box to input your new username.
Type your new username and tap on “Save Changes”
This will change your username immediately.

This also applies to your bio, just tap on the edit button, and add your bio. And this will add or edit your bio immediately.

Create a new blog:
Tap on this button named “Write your blog”. This will show a dialog box to enter necessary content.
Enter your title, and your blog description. And in every post, an image is a MUST. Tap on “Continue” to proceed.

Editing your blog post:
Same steps to edit your post, the post content is still saved and returned for editing your title, your description, and your image.
To delete your post, tap on the “🗑️” button to delete your post.

Chats
1:1 Chats  
Tap on the hamburger icon to show the menu and tap on “Message users”. This will direct you to a user selection page.
Tap on any user to start a conversation.  
Now, type your first message and tap “Send”. Your message will be set to your recipient. You may send a photo to your recipient by tapping on an “Image” icon. Pick your desired image and tap on the “Send” button.  
All messages will have local notifications within the chat page. When the user receives a photo, it only notifies the user ‘sent a photo’.
All text messages have their Text To Speech. Tap on every message to listen to the spoken text. Images cannot be spoken into Text To Speech of course.

A designated help button is shown on the top-right corner of the AppBar. Tap on it to show the help dialog.
Long tap on a text message or a photo to delete a message.
To delete, tap on ‘Continue’. Otherwise, tap on ‘Cancel’.
This will delete your sent message or your sent photo.

Group Chats.  
Chat with multiple friends at once. This group chat feature lets you talk, share photos, and make plans together in one convenient conversation. Plus, you can view members and change the group chat picture to personalize your experience.
To create a group chat, tap on the “ellipsis” icon located on the top-right corner of the page. Then tap on ‘Create Group Chat’.
This will direct you to the Create Group chat page.
Name your group chat and add registered users to your group chat.  
Tap on each user to select or deselect your group. Then tap on ‘Create Group’. A message on the bottom will notify you that the group chat has been added successfully. Tap on your newly created group to enter a group chat and enjoy your conversation.

Weather API
OpenWeather API
Weather updates apply page themes from varied weather conditions. Theme colors only apply to this page, and not on the whole application’s interface. This also applies to devices with dark mode.
This page only shows the current weather updates every minute.
Weather icons, temperature, and weather conditions also change dynamically.

Logging out.  
On the homepage, tap on the hamburger icon. On the bottom, tap on ‘Logout’

A dialog box appears to confirm the user to log out.

Tap on ‘Continue’ to proceed, otherwise tap on ‘Cancel’.
This will direct the user to the login page.



