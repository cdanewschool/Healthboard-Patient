package edu.newschool.piim.healthboard.model
{
	import edu.newschool.piim.healthboard.enum.AppContext;

	public class PatientApplicationModel extends ApplicationModel
	{
		public function PatientApplicationModel()
		{
			super( AppContext.PATIENT );
		}
	}
}