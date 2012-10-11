package controllers
{
	import ASclasses.Constants;
	
	import controllers.Controller;
	
	import events.ApplicationEvent;
	
	import external.TabBarPlus.plus.TabBarPlus;
	
	import mx.collections.IList;
	import mx.events.ListEvent;
	
	public class MainController extends Controller
	{
		public function MainController()
		{
			super();
			
			appointmentsController = new PatientAppointmentsController();
			exerciseController = new PatientExerciseController();
			immunizationsController = new PatientImmunizationsController();
			medicalRecordsController = new PatientMedicalRecordsController();
			medicationsController = new PatientMedicationsController();
			nutritionController = new NutritionController();
			vitalSignsController = new VitalSignsController();
		}
		
		override protected function onSetState( event:ApplicationEvent ):void
		{
			super.onSetState( event );
			
			var dashboard:visualDashboard = application as visualDashboard;
			
			if( application.currentState == Constants.MODULE_MESSAGES )
			{
				/**
				 * howToHandleMessageTabs is a fix; if we call createNewMessage from the appointments module (i.e. sending a msg to a doctor or nurse) or viewMessage 
				 * from the Widgets module before the messages module has been created, then it messes up everything... so, the first time we want to createNewMessage 
				 * from appts or viewMessage from Widgets, we just set it to "viewWidgetMessage" or "createApptsMessage", and the corresponding function will be called 
				 * from the messages module instead...
				 */
				
				if( dashboard.howToHandleMessageTabs != "not created" ) 
				{
					dashboard.createNewMessage( event.message ? event.message.recipientType : 1 );
					
					dashboard.tabsMessages.selectedIndex = dashboard.viewStackMessages.length - 2;
				}
				else dashboard.howToHandleMessageTabs = "createApptsMessage";
			}
		}
		
		override protected function onTabClose(event:ListEvent):void
		{
			super.onTabClose(event);
			
			var dashboard:visualDashboard = application as visualDashboard;
			
			if( TabBarPlus( event.target.owner).dataProvider is IList )
			{
				var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
				var index:int = event.rowIndex;
				
				if( dataProvider == dashboard.viewStackMessages ) 
				{
					//	this array will hold the index values of each "NEW" message in arrOpenTabs. Its purpose is to know which "NEW" message we're closing (if it is in fact a new message)
					var arrNewMessagesInOpenTabs:Array = new Array(); 
					
					for(var i:uint = 0; i < dashboard.arrOpenTabs.length; i++) 
					{
						if( dashboard.arrOpenTabs[i] == "NEW") arrNewMessagesInOpenTabs.push(i);
					}
					
					if( dashboard.arrOpenTabs[index-1] == "NEW" ) 
						dashboard.arrNewMessages.splice( arrNewMessagesInOpenTabs.indexOf(index-1), 1 );
					
					dashboard.arrOpenTabs.splice(index-1,1);
					dashboard.viewStackMessages.selectedIndex--;
				}
				else if( application.currentState == "modMedications" ) 
				{
					medicationsController.model.openTabs.splice(index-1,1);
				}
				else if( application.currentState == "modImmunizations" ) 
				{
					immunizationsController.model.openTabs.splice(index-1,1);
				}
			}
			else 
			{
				trace("Bad data provider");
			}
		}
	}
}