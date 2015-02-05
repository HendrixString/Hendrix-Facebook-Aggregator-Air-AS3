package com.hendrix.facebook.aggregator.core.interfaces
{
  /**
   * a common inteface for objects that have an <code>id</code> property.
   * @author Tomer Shalev
   */
  public interface IId
  {
    /**
     * a common <code>id</code>. 
     */
    function get id():              String;
    function set id(value: String): void;
  }
}