# HelloID-Conn-Prov-Target-Blackboard
 Currently a work in progress
 
# Setup REST API Integration
 1.	Visit https://developer.blackboard.com/
 2.	Click Register and sign up for a Blackboard Developer account
 3.	Once you get to the My Applications page click the + symbol in the top right
 4.	Fill out the form with the required info on the form, you don’t have to worry about the other info on the form.
 5.	On the next page make sure to copy down all the info and store it in a safe space this is the info that will be used to register the application with your Blackboard instance and will be used by our application to authenticate with. Click done.
 6.	On the next page you should see your new integration you are going to want to copy the Application ID this will be used in the next step.
 7.	In your Blackboard instance go to System Admin > REST API Integrations on the top you are going to want to click on Create Integration
 8.	On the next page you are going to want to enter in the Application ID you copied from step #6. You will need to select a user that the integration will use, the permissions of the user should be enough so we can perform any actions you need us to perform.
 9.	After you hit Submit you are done the most important items that we will need for the authentication will be the Application Key and Secret which you received from step #5