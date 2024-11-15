//Generated for Decodeforce programming test
public class stringCheckController{

	public static boolean keywordExist(String input){

		Boolean result;

		/* Write your logic below */

        String salesforce = 'salesforce';

        if(!input.contains(salesforce)) {
            result = false;
        } else {
            result = true;
        }



		return result;
	
	}
}