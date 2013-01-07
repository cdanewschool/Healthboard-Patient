package controllers
{
	import ASclasses.Constants;
	import ASclasses.PatientConstants;
	
	import components.home.NextStepsOverlay;
	import components.home.preferencesWindow;
	import components.widgets.EducationalResourcesWidget;
	
	import enum.ViewModeType;
	
	import events.ApplicationDataEvent;
	import events.ApplicationEvent;
	import events.AuthenticationEvent;
	
	import external.TabBarPlus.plus.TabBarPlus;
	
	import models.PatientApplicationModel;
	import models.PatientsModel;
	import models.Preferences;
	import models.UserModel;
	import models.UserPreferences;
	import models.modules.MessagesModel;
	
	import modules.NutritionModule;
	
	import mx.collections.IList;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexMouseEvent;
	import mx.events.ListEvent;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	
	public class MainController extends Controller
	{
		[Bindable] public var nextStepsOverlay:NextStepsOverlay;
		
		public function MainController()
		{
			super();
			
			model = new PatientApplicationModel();
			
			appointmentsController = new PatientAppointmentsController();
			exerciseController = new PatientExerciseController();
			immunizationsController = new PatientImmunizationsController();
			medicalRecordsController = new PatientMedicalRecordsController();
			medicationsController = new PatientMedicationsController();
			nutritionController = new NutritionController();
			vitalSignsController = new VitalSignsController();
			
			patientsController.model.addEventListener( ApplicationDataEvent.LOADED, onPatientsLoaded );
			
			loadStyles();
		}
		
		override protected function onInitialized():void
		{
			if( !initialized ) return;
			
			if( Constants.DEBUG ) 
			{
				for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
				{
					if( patient.id == PatientConstants.DEBUG_USER_ID ) 
					{
						model.user = patient;
						
						application.dispatchEvent( new AuthenticationEvent( AuthenticationEvent.SUCCESS, true ) );
						
						break;
					}
				}
			}
		}
		
		override public function validateUser( username:String, password:String ):UserModel
		{
			for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
			{
				if( patient.username == username && patient.password == password ) 
				{
					return patient;
				}
			}
			
			return null;
		}
		
		override public function getDefaultUser():UserModel
		{
			for each(var patient:UserModel in PatientsModel(patientsController.model).patients)
			{
				if( patient.id == PatientConstants.DEBUG_USER_ID ) 
				{
					return patient;
				}
			}
			
			return null;
		}
		
		override public function showPreferences():UIComponent
		{
			var popup:preferencesWindow = preferencesWindow( PopUpManager.createPopUp(application, preferencesWindow) as TitleWindow );
			popup.preferences = model.preferences.clone() as UserPreferences;
			PopUpManager.centerPopUp(popup);
			
			return popup;
		}
		
		override protected function loadPreferences():void
		{
			if( persistentData 
				&& persistentData.data.hasOwnProperty('preferences') )
			{
				model.preferences = UserPreferences.fromObj( persistentData.data['preferences'] );
			}
			else
			{
				model.preferences = new UserPreferences();
				savePreferences( model.preferences );
			}
			
			processPreferences();
		}
		
		override public function savePreferences( preferences:Preferences ):void
		{
			super.savePreferences(preferences);
			
			persistentData.data['preferences'] = preferences;
			persistentData.flush();
		}
		
		override protected function processPreferences( preferences:Preferences = null ):void
		{
			if( preferences == null ) preferences  = model.preferences;
			
			super.processPreferences( preferences );
			
			if( preferences 
				&& preferences.viewMode != model.preferences.viewMode )
			{
				var state:String = preferences.viewMode == ViewModeType.WIDGET ? Constants.STATE_WIDGET_VIEW : Constants.STATE_LOGGED_IN;
				
				application.dispatchEvent( new ApplicationEvent( ApplicationEvent.SET_STATE, true, false, state) );
			}
		}
		
		public function showNextStepsOverlay():void
		{
			if( nextStepsOverlay ) 
			{
				onNextStepsClose()
				
				return;
			}
			
			nextStepsOverlay= PopUpManager.createPopUp( application, NextStepsOverlay ) as NextStepsOverlay;
			nextStepsOverlay.addEventListener( CloseEvent.CLOSE, onNextStepsClose );
			nextStepsOverlay.addEventListener(FlexMouseEvent.MOUSE_DOWN_OUTSIDE, onNextStepsOutsideClick);
			
			nextStepsOverlay.x = application.stage.width/2 - nextStepsOverlay.width/2;
			nextStepsOverlay.y = visualDashboard(application).header.height - 1;
		}
		
		private function onNextStepsClose( event:CloseEvent = null ):void
		{
			PopUpManager.removePopUp( nextStepsOverlay );
			
			nextStepsOverlay.removeEventListener( CloseEvent.CLOSE, onNextStepsClose );
			nextStepsOverlay = null;
		}
		
		private function onNextStepsOutsideClick( event:FlexMouseEvent = null ):void
		{
			if(!visualDashboard(application).nextStepsTrigger.hitTestPoint(event.stageX,event.stageY)) onNextStepsClose();
		}
		
		override protected function onAuthenticated(event:AuthenticationEvent):void
		{
			if( !initialized )
			{
				medicationsController.init();
			}
			
			super.onAuthenticated( event );
		}
		
		override protected function onNavigate( event:ApplicationEvent ):void
		{
			super.onNavigate(event);

			closeNextStepsOverlay();
		}
		
		override protected function onSetState( event:ApplicationEvent ):void
		{
			super.onSetState( event );
			
			var dashboard:visualDashboard = application as visualDashboard;
			
			if( application.currentState == Constants.MODULE_MESSAGES
				&& event.message )
			{
				MessagesModel(messagesController.model).pendingRecipientType = event.message.recipientType;
			}
			else if( application.currentState == Constants.MODULE_EDUCATIONAL_RESOURCES )
			{
				if( event.target is NutritionModule )
				{
					dashboard.educationalResourcesModule.viewsEducationalResources.selectedIndex = 1; 
					dashboard.educationalResourcesModule.viewsEducationalResourcesMenu.selectedIndex = 1; 
					dashboard.educationalResourcesModule.viewsEducationalResourcesBreadcrumb.selectedIndex = 1;
				}
				else if( event.target is EducationalResourcesWidget )
				{
					if( dashboard.widgetEducationalResources.viewIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResources.selectedIndex = dashboard.widgetEducationalResources.viewIndex;
					
					if( dashboard.widgetEducationalResources.menuIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResourcesMenu.selectedIndex = dashboard.widgetEducationalResources.menuIndex;
					
					if( dashboard.widgetEducationalResources.breadcrumbIndex > -1 )
						dashboard.educationalResourcesModule.viewsEducationalResourcesBreadcrumb.selectedIndex = dashboard.widgetEducationalResources.breadcrumbIndex;
				}
				
			}
			
			closeNextStepsOverlay();
		}
		
		override protected function onTabClose(event:ListEvent):void
		{
			super.onTabClose(event);
			
			var dashboard:visualDashboard = application as visualDashboard;
			
			if( TabBarPlus( event.target.owner).dataProvider is IList )
			{
				var dataProvider:IList = TabBarPlus( event.target.owner).dataProvider as IList;
				var index:int = event.rowIndex;
				
				if( application.currentState == "modMedications" ) 
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
		
		private function closeNextStepsOverlay():void
		{
			if( nextStepsOverlay
				&& nextStepsOverlay.parent )
			{
				nextStepsOverlay.dispatchEvent( new CloseEvent( CloseEvent.CLOSE, true ) );
				
				nextStepsOverlay = null;
			}
		}
		
		override protected function get id():String
		{
			return 'visualDashboardPatient';
		}
	}
}