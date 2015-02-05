package com.hendrix.facebook.aggregator
{
  import flash.utils.Dictionary;
  
  import com.hendrix.facebook.aggregator.core.AggregatorBase;
  
  /**
   * Facebook feed aggregator, non filtered.
   * 
   * @author Tomer Shalev
   */
  public class CommentsAggregator extends AggregatorBase
  {
    protected var _postId:                      String        = null;
    private var _postInfo:Object = null;
    private var _userDic:Dictionary = null;
    
    private var _mapFqlResults:Dictionary = null;
    
    /**
     * Facebook posts aggregator.
     * @param $pageId the Facebook page id to be aggregated
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function CommentsAggregator($postId: String, $access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      super($access_token, $access_tokenExpiry);
      
      
      _postId = $postId;
      
      _userDic = new Dictionary(true);
      
      _mapFqlResults = new Dictionary();
    }
    
    /**
     * @inheritDoc
     */
    override public function refreshFeed($onWallFeedUpdate:Function = null):Boolean
    {
      _fql["comments"]                = "SELECT fromid,text,post_id,time,likes FROM comment WHERE post_id='" + _postId + "'" + " ORDER BY time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT fromid FROM #comments))";
      _fql["post_info"]               = "SELECT like_info,comment_info,share_info FROM stream WHERE post_id='" + _postId + "'";
      
      return (super.refreshFeed($onWallFeedUpdate));
    }
    
    /**
     * @inheritDoc
     */
    override public function nextPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      _fql["comments"]                = "SELECT fromid,text,post_id,time,likes FROM comment WHERE post_id='" + _postId + "' and time<" + _posts[_posts.length - 1].time + " ORDER BY time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT fromid FROM #comments))";
      _fql["post_info"]               = "SELECT like_info,comment_info,share_info FROM stream WHERE post_id='" + _postId + "'";
      
      return (super.nextPageFeed($onWallFeedUpdate));
    }
    
    /**
     * @inheritDoc
     */
    override public function prevPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      _fql["comments"]                = "SELECT fromid,text,post_id,time,likes FROM comment WHERE post_id='" + _postId + "' and time>" + _posts[0].time + " ORDER BY time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT fromid FROM #comments))";
      _fql["post_info"]               = "SELECT like_info,comment_info,share_info FROM stream WHERE post_id='" + _postId + "'";
      
      return (super.prevPageFeed($onWallFeedUpdate));
    }
    
    
    private function mapRsults($feed:Object = null):void
    {
      for(var ix:uint = 0; ix < $feed.data.length; ix++) {
        _mapFqlResults[$feed.data[ix].name] = $feed.data[ix].fql_result_set;
      }
    }
    
    /**
     * @inheritDoc
     */
    override public function processFeed($feed:Object, $position:String = "BOTTOM"):uint
    {
      mapRsults($feed);
      
      var posts:          Array   = _mapFqlResults["comments"] as Array;
      var userInfo:       Array   = _mapFqlResults["users_info"] as Array;
      _postInfo                   = _mapFqlResults["post_info"][0];
      
      var post:           Object  = null;
      var ix:             int;
      
      if(posts.length == 0)
        return 0;
      
      switch($position)
      {
        case "TOP":
        {
          for(ix = 0; ix < posts.length; ix++)  {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.unshift(posts[posts.length - ix - 1]);
          }
          break;
        }
        case "BOTTOM":
        {
          for(ix = 0; ix < posts.length; ix++)  {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.push(posts[ix]);
          }
          break;
        }
        default:
        {
          throw new Error("invalid argument position: should be BOTTOM or TOP");
          break;
        }
      }
      
      for(ix = 0; ix < userInfo.length; ix++) {
        _userDic[userInfo[ix].uid] = userInfo[ix];
      }
      
      for(ix = 0; ix < posts.length; ix++)  {
        posts[ix].users_info = _userDic[posts[ix].fromid];
      }
      
      return posts.length;
    }
    
    public function get postId():String { return _postId; }
    public function set postId(value:String):void { _postId = value;  }
    
    public function get postInfo():Object
    {
      return _postInfo;
    }
    
    public function set postInfo(value:Object):void
    {
      _postInfo = value;
    }
    
    
  }
}