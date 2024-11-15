//Generated for Decodeforce programming test
public class ageController{

	public static Integer calculateAge(date dateOfBirth){

		Integer age;

		/* Write your logic below */

        Date todaysDate = Date.today();

        Integer yearDifference = todaysDate.year() - dateOfBirth.year();

        if(todaysDate > Date.newInstance(todaysDate.year(), dateOfBirth.month(), dateOfBirth.year())) {
            yearDifference--;
            age = yearDifference;
        } else {
            age = yearDifference;
        }

		return age;
	
	}
}