package models
{
	import enum.AppContext;

	public class PatientApplicationModel extends ApplicationModel
	{
		public function PatientApplicationModel()
		{
			super( AppContext.PATIENT );
		}
	}
}