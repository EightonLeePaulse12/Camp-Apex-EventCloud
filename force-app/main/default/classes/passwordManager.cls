//Generated for Decodeforce programming test
public class passwordManager{

	public static boolean isValidPassword(String passwordInput){

		Boolean result;

		/* Write your logic below */

        if(passwordInput.length() >= 8) {
            result = false;
        } else {
            result = true;
        }



		return result;
	
	}
}