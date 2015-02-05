package com.hendrix.facebook.commands
{
  import flash.events.Event;
  
  import com.hendrix.facebook.core.FqlCommand;
  
  /**
   * a simple class to get user statistics of facebook user on a specific facebook page:<br>
   * <li><code>this.stat_posts_i_published_count</code> = the count of posts the user has published on the page.
   * <li><code>this.stat_comments_i_got_count</code> = the count of comments that the posts that were published by the user have got.
   * <li><code>this.stat_likes_i_got_count</code> = the count of likes that the posts that were published by the user have got.
   * <li><code>this.stat_comments_i_published_count</code> = the count of comments that the user has made on posts on that page.
   * @author Tomer Shalev
   */
  public class FbStatistics extends FqlCommand
  {
    protected var _facebookPageId:              String        = null;
    protected var _facebookUserId:              String        = null;
    
    public var  loaded:                         Boolean       = false;
    
    /**
     * return statistics
     */
    public var stat_posts_i_published_count:    uint          = 0;
    public var stat_comments_i_got_count:       uint          = 0;
    public var stat_likes_i_got_count:          uint          = 0;
    public var stat_comments_i_published_count: uint          = 0;
    
    /**
     * a simple class to get user statistics of facebook user on a specific facebook page:<br>
     * <li><code>this.stat_posts_i_published_count</code> = the count of posts the user has published on the page.
     * <li><code>this.stat_comments_i_got_count</code> = the count of comments that the posts that were published by the user have got.
     * <li><code>this.stat_likes_i_got_count</code> = the count of likes that the posts that were published by the user have got.
     * <li><code>this.stat_comments_i_published_count</code> = the count of comments that the user has made on posts on that page.
     * @param $facebookPageId the page on which the user had made actions 
     * @param $facebookUserId the user id that made the actions
     * @param $access_token valid access token
     * @param $access_tokenExpiry expiry date
     * 
     */
    public function FbStatistics($facebookPageId: String, $facebookUserId:String = "me()", $access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      super($access_token, $access_tokenExpiry);
      
      _facebookPageId           = $facebookPageId;
      _facebookUserId           = $facebookUserId;
    }
    
    public function getStatistics($onUpdate:Function = null):Boolean
    {
      if(!isAccessTokenAvailable())
        throw new Error("no access token, or access token has expired");
      
      if(isBusy)
        return false;
      
      cb_onUpdate                     = $onUpdate;
      
      _fql["query1"]                  = "SELECT comment_info, like_info FROM stream WHERE source_id=" + _facebookPageId + " and (actor_id=" + _facebookUserId + ") " + "LIMIT " + 1000;
      _fql["query2"]                  = "SELECT comment_count,fromid FROM comment WHERE (post_id IN (SELECT post_id FROM stream WHERE source_id=" + _facebookPageId + " LIMIT 1000)) and fromid=" + _facebookUserId + " LIMIT " + 1000;
      
      this.loadRequest(_fql, "stats", $onUpdate);
      
      return true;
    }
    
    override protected function onGraphRequestResponse(event:Event, $notifyListener:Boolean = true):void
    {
      try{
        var data: Object          = JSON.parse(event.target.data);
      }
      catch(err:Error) {
        trace(err)
        onGraphRequestFailed();
        return;
      }
      
      _ul.removeEventListener( Event.COMPLETE, onGraphRequestResponse);
      
      var arr:  Array                 = data.data[0].fql_result_set as Array;
      
      stat_posts_i_published_count    = arr.length;
      stat_comments_i_got_count       = 0;
      stat_likes_i_got_count          = 0;
      
      for(var ix: uint = 0 ; ix < arr.length; ix++)
      {
        stat_comments_i_got_count    += uint(arr[ix].comment_info.comment_count);
        stat_likes_i_got_count       += uint(arr[ix].like_info.like_count);
      }
      
      arr                             = data.data[1].fql_result_set as Array;
      stat_comments_i_published_count = arr.length;
      
      loaded                          = true;
      
      if($notifyListener)
        notifyListener(this);
      trace();
    }
    
  }
}