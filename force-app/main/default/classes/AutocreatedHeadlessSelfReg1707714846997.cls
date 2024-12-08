/*
 * Auto Generated Headless Registration Handler
 */
global class AutocreatedHeadlessSelfReg1707714846997 implements Auth.HeadlessSelfRegistrationHandler {

	//Defines the name of the account that contact records should be associated with
	private static final string headless_account = 'My Account';

	/*
	* This method handles filling user data that is required by Salesforce but is not passed in during registration
	* It is not strictly necessary but helpful as it centralizes the management of unnecessary fields to the IDP instead of the client. 
	*/
	void prepareUserData(Auth.UserData data, User u){
		
		String name, firstName, lastName, username, alias, email, phone;
		
		// Initialize the attributes essential for creating a new user with dummy values
		// in case they will not be provided by the Auth Provider
		firstName = 'change-me';
		lastName = 'change-me';
		email = 'change@me.com';
		if(data.email != null && data.email != '')
			email = data.email;
		if(data.firstName != null && data.firstName != '')
			firstName = data.firstName;
		if(data.LastName != null && data.lastName != '')
			lastName = data.lastName;
		if(data.attributeMap.containsKey('full_name'))
			name = data.attributeMap.get('full_name');
		if(data.attributeMap.containsKey('name'))
			name = data.attributeMap.get('name');
		if(firstName == 'change-me' && name != '')
			firstName = name.substringBefore(' ');
		if(lastName == 'change-me' && name.substringAfter(' ') != '')
			lastName = name.substringAfter(' ');
		if(data.attributeMap.containsKey('phone') && data.attributeMap.get('phone') != null && data.attributeMap.get('phone') != '')
			phone = data.attributeMap.get('phone');
		
		// Generate a random username
		Integer rand = Math.round(Math.random()*100000000);
		if(data.attributeMap.containsKey('username')){
			username = data.attributeMap.get('username');
		}else{
			username = lastName + '.' + rand + '@social-sign-on.com';
		}
		alias = firstName;

		//Alias must be 8 characters or less
		if(alias.length() > 8)
			alias = alias.substring(0, 8);
		u.username = username;
		u.email = email;
		u.lastName = lastName;
		u.firstName = firstName;
		u.mobilephone = phone;
		u.alias = alias;
		u.languagelocalekey = UserInfo.getLocale();
		u.localesidkey = UserInfo.getLocale();
		u.emailEncodingKey = 'UTF-8';

		//The auto generated handler automatically sets the timezone from the UserInfo object
		// your app should use the customDataMap attribute to pass timezone information from your client 
		// into the registration handler 
		TimeZone tz = UserInfo.getTimeZone();
		u.timeZoneSidKey = tz.getID();
	}


	// Creates a Standard salesforce or a community user
	global User createUser(Id profileId, Auth.UserData data, String customUserDataMap, String experienceId, String password){
		User u = new User();
		//Ensures the user will save as all required fields are pre-filled in with dummy values
		prepareUserData(data, u);
		//Get the Account, and create it if one is not already present. 
		Account a;
		List<Account> accounts = [SELECT Id FROM account WHERE name='My Account'];
		if(accounts.isEmpty()) {
			a = new Account(name = headless_account);
			insert(a);
		} else {
			a = accounts[0];
		}
		
		/*
		* Deserialize the custom data into a apex class structure. 
		* Below shows how you could do this, however you must define the appropriate apex class
		*/
		
		//MyClass customDataClass = (MyClass)JSON.deserialize(customUserDataMap, MyClass.class);
		
		// Create the Contact
		Contact c = new Contact();
		c.accountId = a.Id;
		c.firstName = u.firstName;
		c.lastName = u.lastName;
		insert(c);
		
		//Associate the Contact to the user along with the profile. 
		u.profileId = profileId;
		u.contactId = c.Id;
		return u;
	}
	
}