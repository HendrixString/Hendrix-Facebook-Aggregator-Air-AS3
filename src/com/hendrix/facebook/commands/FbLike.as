package com.hendrix.facebook.commands
{
  import flash.net.URLRequestMethod;
  
  import com.hendrix.facebook.core.GraphRequest;
  
  public class FbLike extends GraphRequest
  {
    
    public function FbLike($postId:String, $access_token:String=null, $access_tokenExpiry:Number=-1)
    {
      super($postId + "/likes", URLRequestMethod.POST, $access_token, $access_tokenExpiry);
    }
    
    /**
     * we are reusing this instance over and over that's why i modify the url. 
     * @param $postId
     * @param $onUpdate
     * 
     */
    public function postLike($postId:String = null, $onUpdate:Function = null):void
    {
      stopRequest();
      
      if($postId)
        _ur.url             = "https://graph.facebook.com/" + $postId + "/likes";
      
      loadRequest(params, null, $onUpdate);
    }
    
  }
}