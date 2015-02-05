package com.hendrix.facebook.commands
{
  import flash.events.Event;
  
  import com.hendrix.facebook.core.FqlCommand;
  
  /**
   * a small class for getting user info 
   * @author Tomer Shalev
   */
  public class FbUserInfo extends FqlCommand
  {
    private var _userFacebookId:  String    = null;
    
    /**
     * user info
     */
    public var birthday_date:     String    = null;
    public var sex:               String    = null;
    public var userName:          String    = null;
    public var userProfilePicSrc: String    = null;
    
    public var loaded:            Boolean   = false;
    /**
     * a small class for getting user info 
     * @param $userFacebookId the facebook user id
     * @param $access_token a valid access token
     * @param $access_tokenExpiry token expiry date
     */
    public function FbUserInfo($userFacebookId:String = "me()", $access_token:String=null, $access_tokenExpiry:Number=-1)
    {
      super($access_token, $access_tokenExpiry);
      
      _userFacebookId = $userFacebookId;
    }
    
    public function getUserInfo($onUpdate:Function = null):Boolean
    {
      if(loaded)
        notifyListener(this);
      
      loaded                      = false;
      
      if(!isAccessTokenAvailable())
        throw new Error("no access token, or access token has expired");
      
      if(isBusy)
        return false;
      
      _fql["query1"]                  = "SELECT pic_big,name FROM user WHERE uid=" + _userFacebookId;
      
      loadRequest(_fql, null, $onUpdate);
      
      return true;
    }
    
    override protected function onGraphRequestResponse(event:Event, $notifyListener:Boolean = true):void
    {
      super.onGraphRequestResponse(event, false);
      
      var arr:  Array             = _dataLatest.data[0].fql_result_set as Array;
      
      if(arr.length == 0)
        return;
      
      userName                    = arr[0].name;
      userProfilePicSrc           = arr[0].pic_big;
      birthday_date               = arr[0].birthday_date;
      sex                         = arr[0].sex;
      
      loaded                      = true;
      
      if($notifyListener)
        notifyListener(this);
    }
    
  }
}