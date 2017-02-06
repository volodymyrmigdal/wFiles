( function _FileBase_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  wTools.include( 'wProto' );
  wTools.include( 'wRegexpObject' );
  wTools.include( 'wLogger' );
  wTools.include( 'wPath' );

  // if( typeof wRegexpObject === 'undefined' )
  // try
  // {
  //   require( '../../abase/object/RegexpObject.s' );
  // }
  // catch( err )
  // {
  //   require( 'wRegexpObject' );
  // }
  //
  // if( typeof wTools === 'undefined' || !wTools.mixin )
  // try
  // {
  //   require( '../../abase/component/Proto.s' );
  // }
  // catch( err )
  // {
  //   require( 'wProto' );
  // }
  //
  // if( typeof logger === 'undefined' )
  // try
  // {
  //   require( '../../abase/object/printer/printer/Logger.s' );
  // }
  // catch( err )
  // {
  // }
  //
  // if( typeof wConsequence === 'undefined' )
  // try
  // {
  //   require( '../../abase/syn/Consequence.s' );
  // }
  // catch( err )
  // {
  //   require( 'wConsequence' );
  // }
  //
  // if( typeof wTools === 'undefined' || !wTools.pathDir )
  // try
  // {
  //   require( '../../abase/component/Path.s' );
  // }
  // catch( err )
  // {
  //   require( 'wPath' );
  // }

}

var Self = wTools;
var _ = wTools;

// --
// var
// --

var FileProvider =
{
}

// --
// prototype
// --

var Proto =
{

}

_.mapExtend( _,Proto );
Self.FileProvider = _.mapExtend( Self.FileProvider || {},FileProvider );

// export

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}


})();
