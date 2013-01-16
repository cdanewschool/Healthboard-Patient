package edu.newschool.piim.healthboard.model
{
	import enum.AppContext;
	import models.ApplicationModel;

	public class PatientApplicationModel extends ApplicationModel
	{
		public function PatientApplicationModel()
		{
			super( AppContext.PATIENT );
		}
	}
}