//Generated for Decodeforce programming test
public class validateStringController{

	public static boolean isValidInput(String inputString){

		Boolean isValid;

		/* Write your logic below */

        if(inputString.length() <= 40) {
            isValid = true;
        } else {
            isValid = false;
        }



		return isValid;
	
	}
}