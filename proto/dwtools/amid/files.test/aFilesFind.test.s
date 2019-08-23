( function _FilesFind_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );

  require( '../files/UseTop.s' );

  var crypto = require( 'crypto' );
  var waitSync = require( 'wait-sync' );

}

//

var _ = _global_.wTools;
var Parent = wTester;

// --
// context
// --

function onSuiteBegin( test )
{
  let context = this;
}

//

function onSuiteEnd()
{
  let path = this.provider.path;
  _.assert( Object.keys( this.hub.providersWithProtocolMap ).length === 1, 'Hub should have single registered provider at the end of testing' );
  _.assert( _.strHas( this.testSuitePath, 'tmp.tmp' ) );
  path.dirTempClose( this.testSuitePath );
  this.provider.finit();
  this.hub.finit();
}

//

function onRoutineEnd( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  _.sure( _.entityIdentical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] ), test.name, 'has not restored hub!' );
}

//

function softLinkIsSupported()
{
  let context = this;
  let path = context.provider.path;

  if( Config.platform === 'nodejs' && typeof process !== undefined )
  if( process.platform === 'win32' )
  {
    var allow = false;
    var dir = path.join( context.testSuitePath, 'softLinkIsSupported' );
    var srcPath = path.join( dir, 'src' );
    var dstPath = path.join( dir, 'dst' );

    _.fileProvider.filesDelete( dir );
    _.fileProvider.fileWrite( srcPath, srcPath );

    try
    {
      _.fileProvider.softLink({ dstPath : dstPath, srcPath : srcPath, throwing : 1, sync : 1 });
      allow = _.fileProvider.isSoftLink( dstPath );
    }
    catch( err )
    {
      logger.error( err );
    }

    return allow;
  }

  return true;
}

//

function makeStandardExtract( o )
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  var extract = _.FileProvider.Extract
  ({
    filesTree :
    {
      src1 :
      {
        a : '/src1/a',
        b : '/src1/b',
        c : '/src1/c',
        d :
        {
          a : '/src1/d/a',
          b : '/src1/d/b',
          c : '/src1/d/c',
        }
      },
      src1b :
      {
        a : '/src1b/a',
      },
      src1Terminal : '/src1Terminal',
      srcT : '/srcT',
      src2 :
      {
        a : '/src2/a',
        b : '/src2/b',
        c : '/src2/c',
        d :
        {
          a : '/src2/d/a',
          b : '/src2/d/b',
          c : '/src2/d/c',
        }
      },

      'src3.s' :
      {
        a : '/src3.s/a',
        'b.s' : '/src3.s/b.s',
        'c.js' : '/src3.s/c.js',
        d :
        {
          a : '/src3.s/d/a',
        }
      },
      'src3.js' :
      {
        a : '/src3.js/a',
        'b.s' : '/src3.js/b.s',
        'c.js' : '/src3.js/c.js',
        d :
        {
          a : '/src3.js/d/a',
        }
      },

      src : { f : '/src/f' },

      alt :
      {
        a : '/alt/a',
        d :
        {
          a : '/alt/d/a',
        }
      },
      alt2 :
      {
        a : '/alt2/a',
        d :
        {
          a : '/alt2/d/a',
        }
      },
      altalt :
      {
        a : '/altalt/a',
        d :
        {
          a : '/altalt/d/a',
        }
      },
      altalt2 :
      {
        a : '/altalt2/a',
        d :
        {
          a : '/altalt2/d/a',
        }
      },

      ctrl :
      {
        a : '/ctrl/a',
        d :
        {
          a : '/ctrl/d/a',
        }
      },
      ctrl2 :
      {
        a : '/ctrl2/a',
        d :
        {
          a : '/ctrl2/d/a',
        }
      },
      ctrlctrl :
      {
        a : '/ctrlctrl/a',
        d :
        {
          a : '/ctrlctrl/d/a',
        }
      },
      ctrlctrl2 :
      {
        a : '/ctrlctrl2/a',
        d :
        {
          a : '/ctrlctrl2/d/a',
        }
      },

      altctrl :
      {
        a : '/altctrl/a',
        d :
        {
          a : '/altctrl/d/a',
        }
      },

      altctrl2 :
      {
        a : '/altctrl2/a',
        d :
        {
          a : '/altctrl2/d/a',
        }
      },

      altctrlalt :
      {
        a : '/altctrlalt/a',
        d :
        {
          a : '/altctrlalt/d/a',
        }
      },

      altctrlalt2 :
      {
        a : '/altctrlalt2/a',
        d :
        {
          a : '/altctrlalt2/d/a',
        }
      },

      doubledir :
      {
        a : '/doubledir/a',
        d1 :
        {
          a : '/doubledir/d1/a',
          d11 :
          {
            b : '/doubledir/d1/d11/b',
            c : '/doubledir/d1/d11/c',
          },
        },
        d2 :
        {
          b : '/doubledir/d2/b',
          d22 :
          {
            c : '/doubledir/d2/d22/c',
            d : '/doubledir/d2/d22/d',
          },
        },
      },

    },
  });

  if( o )
  _.mapExtend( extract, o )

  return extract;
}

// --
// test
// --

function filesFindTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  test.case = 'setup';

  extract1.filesReflectTo( provider, routinePath );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find single terminal file . includingTransient : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1 }
  test.case = 'find single terminal file . includingTransient : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : '1',
    },
  });

  test.case = 'setup trivial';

  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );
  var gotTree = provider.filesExtract( routinePath );
  gotTree.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    gotTree.fileWrite( r.absolute, gotTree.fileRead( r.absolute ) );
  }})
  test.identical( gotTree.filesTree, extract1.filesTree );

  extract1.filesReflectTo( provider, routinePath );

  /* */

  var o1 = { filePath : path.join( routinePath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingTerminals : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 0 }
  test.case = 'find single terminal file . includingTerminals : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath, 'f' ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1 }
  test.case = 'find single terminal file . includingStem : 0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [];
  test.identical( got, expected );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  test.case = 'setup trivial';

  provider.filesDelete( routinePath );
  extract1.filesReflectTo({ dstProvider : provider, dst : routinePath });
  var gotTree = provider.filesExtract( routinePath );
  gotTree.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    gotTree.fileWrite( r.absolute, gotTree.fileRead( r.absolute ) );
  }})
  test.identical( gotTree.filesTree, extract1.filesTree );
  extract1.filesReflectTo( provider, routinePath );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find includingStem : 1';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 0, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find includingStem:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1', './dir1/a', './dir1/b', './dir1/dir11', './dir2', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 0 }
  test.case = 'find includingTransient:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './d', './dir1/a', './dir1/b', './dir2/c' ];
  test.identical( got, expected );

  /* */

  var o1 = { filePath : path.join( routinePath ), outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 0, includingDirs : 1 }
  test.case = 'find includingTerminals:0';

  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './dir1', './dir1/dir11', './dir2' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : null, '**b**' : 0 };
  var filter = { prefixPath : path.join( routinePath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : '', '**b**' : 0 };
  var filter = { prefixPath : path.join( routinePath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : true, '**b**' : 0 };
  var filter = { prefixPath : path.join( routinePath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ]
  test.identical( got, expected );

  /* */

  var filePath = { 'dir1' : null, '**b**' : 0, '**a**' : 1 };
  var filter = { prefixPath : path.join( routinePath ), filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 1, includingTerminals : 1, includingDirs : 1 }
  test.case = 'find with excluding file path';
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ '.', './a', './dir11' ];
  test.identical( got, expected );

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : 'dir1', b : 'dir1', dir11 : { a : 'dir11', b : 'dir11', c : 'dir11' }, dira : {}, dirb : {} },
      dir2 : { a : 'dir2', b : 'dir2', c : 'dir2' },
      d : '/',
    },
  });

  test.case = 'setup trivial';
  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );

  test.case = 'several nulls';
  var filePath = { [ abs( 'dir1/' + '**a**' ) ] : null, [ abs( 'dir1/' + '**b**' ) ] : null };
  var filter = { filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1, includingDirs : 1 }
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './a', './b', './dir11/a', './dir11/b', './dira', './dirb' ];
  test.identical( got, expected );

  test.case = 'several nulls : { dir1/**a** : null, dir2**b** : null }';
  var filePath = { [ abs( 'dir1/' + '**a**' ) ] : null, [ abs( 'dir2' + '**b**' ) ] : null };
  var filter = { filePath : filePath }
  var o1 = { filter : filter, outputFormat : 'relative' }
  var o2 = { recursive : 2, includingStem : 1, includingTransient : 0, includingTerminals : 1, includingDirs : 1 }
  var got = provider.filesFind( _.mapExtend( null, o1, o2 ) );
  var expected = [ './dir2/b', './a', './dir11/a', './dira' ];
  test.identical( got, expected );

  provider.filesDelete( routinePath );
}

//

function filesFindTrivialAsync( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let con = new _.Consequence().take( null );

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 : { a : '1', b : '1', dir11 : {} },
      dir2 : { c : '1' },
      d : '1',
    },
  });

  test.case = 'setup trivial';

  provider.filesDelete( routinePath );
  extract1.filesReflectTo({ dstProvider : provider, dst : context.testSuitePath });
  var gotTree = provider.filesExtract( context.testSuitePath );
  gotTree.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    gotTree.fileWrite( r.absolute, gotTree.fileRead( r.absolute ) );
  }})
  test.identical( gotTree.filesTree, extract1.filesTree );

  extract1.filesReflectTo( provider, context.testSuitePath );

  //

  con.then( () =>
  {
    test.case = 'trivial async';
    var o =
    {
      filePath : path.join( context.testSuitePath ),
      outputFormat : 'relative',
      sync : 0,
      recursive : 2,
      includingTerminals : 1,
      includingDirs : 1
    }

    return provider.filesFind( _.mapExtend( null, o ) )
    .finally( ( err, got ) =>
    {
      test.identical( err, undefined );
      var expected =
      [
        '.',
        './d',
        './dir1',
        './dir1/a',
        './dir1/b',
        './dir1/dir11',
        './dir2',
        './dir2/c'
      ]
      test.identical( got, expected )
      return null;
    })
  })

  return con;
}

//

function filesFindMaskTerminal( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  var terminalPath = path.join( routinePath, 'package.json' );

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );

  test.case = 'relative to current dir';

  var filter =  { maskTerminal : './package.json' }
  var got = provider.filesFind({ filePath : routinePath, filter : filter, recursive : 1 });
  test.identical( got.length, 1 );

  /* */

  test.case = 'relative to parent dir';

  var filter =  { maskTerminal : './filesFindMaskTerminal/package.json' }
  var got = provider.filesFind({ filePath : routinePath, filter : filter });
  test.identical( got.length, 0 );

}

//

function filesFindCriticalCases( test )
{
  let context = this
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let provider = context.provider;
  let hub = context.hub;

  /* */

  test.case = 'base path + empty file path';

  var extract = _.FileProvider.Extract
  ({
    filesTree : {},
  });

  var got = extract.filesFind
  ({
    filter : { basePath : '/' },
    filePath : [],
  });
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'filePath : filter';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : '1', b : '2' }, e : '5' },
  });

  extract.protocol = 'src';
  extract.providerRegisterTo( hub );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  extract.finit();

  var filter = provider.recordFilter({ filePath : routinePath + '/dir1' });
  var got = provider.filesFind({ filePath : filter });
  var relative = _.select( got, '*/relative' );
  var expectedRelative = [ './a', './b' ];

  test.identical( relative, expectedRelative );

  /* */

  test.case = 'extract : empty file path array';

  var extract = _.FileProvider.Extract
  ({
    filesTree : {},
  });

  var got = extract.filesFind([]);
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'hub : empty file path array';

  var hub2 = _.FileProvider.Hub({ providers : [] });
  _.FileProvider.Extract({ protocol : 'ext1' }).providerRegisterTo( hub2 );
  _.FileProvider.Extract({ protocol : 'ext2' }).providerRegisterTo( hub2 );

  var got = hub2.filesFind([]);
  var expected = [];
  test.identical( got, expected );

  /* */

  test.case = 'filePath:null';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 },
  });

  var filter = extract.recordFilter
  ({
    basePath : '.',
    prefixPath : '/',
  });

  filter.filePath = [ '/dir1', '/dir2' ];
  filter._formPaths();
  var found = extract.filesFind
  ({
    recursive : 2,
    includingDirs : 1,
    includingTerminals : 1,
    mandatory : 0,
    outputFormat : 'relative',
    filter : filter,
  });

  var expected = [ './dir1', './dir1/a', './dir1/b', './dir2', './dir2/c' ];
  test.identical( found, expected );

  /* */

  test.case = 'base path + empty file path';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 },
  });

  let op =
  {
    'filePath' : '/dir1',
    'recursive' : null,
    'filter' :
    {
      'maskTerminal' :
      {
        'excludeAny' :
        [
          /\.DS_Store$/,
          /(^|\/)-/,
          /\.out(\.|$)/,
        ],
        'includeAll' : []
      }
    },
    'maskPreset' : 0,
    outputFormat : 'relative',
  }

  var got = extract.filesFind( op );
  var expected = [ './a', './b' ];
  test.identical( got, expected );

  /* */

  var filesTree =
  {
    src :
    {
      dir1 : {},
      dir2 :
      {
        '-Excluded.js' : `console.log( 'dir2/-Ecluded.js' );`,
        'File.js' : `console.log( 'dir2/File.js' );`,
        'File.test.js' : `console.log( 'dir2/File.test.js' );`,
        'File1.debug.js' : `console.log( 'dir2/File1.debug.js' );`,
        'File1.release.js' : `console.log( 'dir2/File1.release.js' );`,
        'File2.debug.js' : `console.log( 'dir2/File2.debug.js' );`,
        'File2.release.js' : `console.log( 'dir2/File2.release.js' );`,
      },
      dir3 :
      {
        'File.js' : `console.log( 'dir3/File.js' );`,
        'File.test.js' : `console.log( 'dir3/File.test.js' );`,
      },
    }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });

  var filter =
  {
    filePath : { '**.test*' : true, '.' : '.' },
    prefixPath : '/src',
    maskAll : { excludeAny : [ /(^|\/)-/, /\.release($|\.|\/)/i ] },
  }

  var got = extract.filesFind({ filter : filter, outputFormat : 'relative' });
  var expected = [ './dir2/File.test.js', './dir3/File.test.js' ];
  test.identical( got, expected );

  var filter =
  {
    filePath : { '**.test*' : false, '**.test/**' : false, '.' : '.' },
    prefixPath : '/src',
    maskAll : { excludeAny : [ /(^|\/)-/, /\.release($|\.|\/)/i ] },
  }

  var got = extract.filesFind({ filter : filter, outputFormat : 'relative' });
  var expected = [ './dir2/File.js', './dir2/File1.debug.js', './dir2/File2.debug.js', './dir3/File.js' ];
  test.identical( got, expected );

  /* */

  test.case = 'both o.filePath and o.filter.filePath defined';

  var filesTree =
  {
    src :
    {
      dir1 : {},
      dir2 :
      {
        '-Excluded.js' : `console.log( 'dir2/-Ecluded.js' );`,
        'File.js' : `console.log( 'dir2/File.js' );`,
        'File.test.js' : `console.log( 'dir2/File.test.js' );`,
        'File1.debug.js' : `console.log( 'dir2/File1.debug.js' );`,
        'File1.release.js' : `console.log( 'dir2/File1.release.js' );`,
        'File2.debug.js' : `console.log( 'dir2/File2.debug.js' );`,
        'File2.release.js' : `console.log( 'dir2/File2.release.js' );`,
      },
      dir3 :
      {
        'File.js' : `console.log( 'dir3/File.js' );`,
        'File.test.js' : `console.log( 'dir3/File.test.js' );`,
      },
    }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });

  var filter = extract.recordFilter
  ({
    basePath : '.',
    prefixPath : '/src',
  });

  filter.filePath = [ 'dir1', 'dir2' ];

  var got = extract.filesFind
  ({
    filePath : 'dir3',
    outputFormat : 'relative',
    filter : filter,
  });

  var expected = [ './dir2/File.js', './dir2/File.test.js', './dir2/File1.debug.js', './dir2/File1.release.js', './dir2/File2.debug.js', './dir2/File2.release.js', './dir3/File.js', './dir3/File.test.js' ];
  test.identical( got, expected );

  // /* */
  //
  // if( Config.debug )
  // {
  //
  //   var filter = extract.recordFilter
  //   ({
  //     basePath : '.',
  //     prefixPath : '/',
  //   });
  //
  //   filter.filePath = [ '/dir1', '/dir2' ];
  //   filter._formPaths();
  //
  //   test.shouldThrowErrorSync( () =>
  //   {
  //
  //     var found = extract.filesFind
  //     ({
  //       mandatory : 0,
  //       filePath : '/',
  //       filter : filter,
  //     });
  //
  //   });
  //
  // }

}

//

function filesFindPreset( test )
{

  test.case = 'preset default.exclude is default';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var found = extract.filesFind
  ({
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : 2,
    filter :
    {
      basePath : '/some/path',
    },
  });

  var expected = [];
  test.identical( found, expected );

  /* */

  test.case = 'double preset';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var o =
  {
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : 2,
    filter :
    {
      basePath : '/some/path',
      maskAll : _.files.regexpMakeSafe( null ),
    },
  }
  var found = extract.filesFind( o );
  var expected = [];
  test.identical( found, expected );

  var maskAll = _.files.regexpMakeSafe();
  test.identical( o.filter.maskAll, maskAll );

  /* */

  test.case = 'off preset';

  var extract = _.FileProvider.Extract
  ({
    filesTree : { '.system' : { dir1 : { a : 1, b : 2 }, dir2 : { c : 3 }, dir3 : { d : 4 }, e : 5 } },
  });

  var found = extract.filesFind
  ({
    filePath : '/.system',
    outputFormat : 'relative',
    recursive : 2,
    maskPreset : 0,

    filter :
    {
      basePath : '/some/path',
    },
  });

  var expected = [ '../../.system/e', '../../.system/dir1/a', '../../.system/dir1/b', '../../.system/dir2/c', '../../.system/dir3/d' ];
  test.identical( found, expected );

  /* */

  test.case = 'dot dir and dot file';

  var extract = _.FileProvider.Extract
  ({
    filesTree :
    {
      'root' :
      {
          '.dir' :
          {
            'a' : 'root/.dir/a',
            '.b' : 'root/.dir/.b',
          },
          'c' : 'root/c',
          '.d' : 'rot/.d',
        }
    },
  });

  var o =
  {
    filePath : '/',
    outputFormat : 'relative',
    includingDirs : 1,
    recursive : 2,
  }
  var found = extract.filesFind( o );
  var expected = [ '.', './root', './root/.d', './root/c' ];
  test.identical( found, expected );

  var o =
  {
    filePath : '/',
    outputFormat : 'relative',
    includingDirs : 0,
    recursive : 2,
  }
  var found = extract.filesFind( o );
  var expected = [ './root/.d', './root/c' ];
  test.identical( found, expected );

}

//

function filesFind( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  if( provider instanceof _.FileProvider.Extract )
  return test.is( true );

  var fixedOptions =
  {
    allowingMissed : 1,
    includingStem : 1,
    result : [],
    orderingExclusion : [],
    sortingWithArray : null,
  }

  /* */

  test.case = 'native path';
  var got = provider.filesFind
  ({
    filePath : __filename,
    includingTerminals : 1,
    includingTransient : 0,
    outputFormat : 'absolute'
  });
  var expected = [ path.normalize( __filename ) ];
  test.identical( got, expected );

  /* */

  test.case = 'check if onUp/onDown was called once per file';

  var onUpMap = {};
  var onDownMap = {};

  var onUp = ( r ) =>
  {
    test.identical( onUpMap[ r.absolute ], undefined )
    onUpMap[ r.absolute ] = 1;
    return r;
  }

  var onDown = ( r ) =>
  {
    test.identical( onDownMap[ r.absolute ], undefined )
    onDownMap[ r.absolute ] = 1;
    // return r;
  }

  var got = provider.filesFind
  ({
    filePath : __dirname,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'absolute',
    onUp : onUp,
    onDown : onDown,
    recursive : 2
  });

  test.is( got.length > 0 );
  test.identical( got.length, _.mapOwnKeys( onUpMap ).length );
  test.identical( got.length, _.mapOwnKeys( onDownMap ).length );

  //

  provider.safe = 1;

  var combinations = [];
  var testsInfo = [];

  var levels = 3;
  var filesNames =
  [
    'a.js', 'a.ss', 'a.s',
    'b.js', 'b.ss', 'b.s',
    'c.js', 'c.ss', 'c.s',
  ];

  var outputFormat = [ 'absolute', 'relative', 'record', 'nothing' ];
  var recursive = [ 0, 1, 2 ];
  var includingTerminals = [ 0, 1 ];
  var includingTransient = [ 0, 1 ];
  var terminalPaths = [ routinePath ];

  var globs =
  [
    null,
    '*',
    '**',
    '*.js',
    '*.ss',
    '*.s',
    'a.*',
    'a.j?',
    '[!ab].s',
    // '{x.*, a.*}' // not supported
  ];

  /* */

  outputFormat.forEach( ( _outputFormat ) =>
  {
    terminalPaths.forEach( ( terminalPath ) =>
    {
      recursive.forEach( ( _recursive ) =>
      {
        includingTerminals.forEach( ( _includingTerminals ) =>
        {
          includingTransient.forEach( ( _includingTransients ) =>
          {
            globs.forEach( ( glob ) =>
            {
              var o =
              {
                outputFormat : _outputFormat,
                recursive : _recursive,
                includingTerminals : _includingTerminals,
                includingTransient : _includingTransients,
                filePath : terminalPath
              };

              if( o.outputFormat !== 'nothing' )
              o.glob = glob;

              _.mapSupplement( o, fixedOptions );
              combinations.push( o );
            })
          });
        });
      });
    })
  });

  /* filesFind test */

  var n = 0;
  for( var l = 2; l < levels; l++ )
  {
    prepareFiles( l );
    combinations.forEach( ( c ) =>
    {
      var info = _.cloneJust( c )
      info.level = l;
      info.number = ++n;
      test.case = _.toStr( info, { levels : 3 } )
      var checks = [];
      var options = _.cloneJust( c );

      if( options.glob !== undefined )
      {
        options.filePath = path.join( options.filePath, options.glob );
        delete options.glob;
      }

      if( options.filePath === null )
      return test.shouldThrowError( () => provider.filesFind( options ) );

      var files = provider.filesFind( options );

      if( options.outputFormat === 'nothing' )
      {
        checks.push( test.identical( files.length, 0 ) );
      }
      else
      {
        /* check result */

        var expected = makeExpected( l, info );
        if( options.outputFormat === 'record' )
        {
          var got = [];
          var areRecords = true;
          files.forEach( ( record ) =>
          {
            if( !( record instanceof _.FileRecord ) )
            areRecords = false;
            got.push( record.absolute );
          });
          checks.push( test.identical( got.sort(), expected.sort() ) );
          checks.push( test.identical( areRecords, true ) );
        }

        if( options.outputFormat === 'absolute' || options.outputFormat === 'relative' )
        {
          logger.log( 'Files:', _.toStr( files.sort() ) );
          logger.log( 'Expected:', _.toStr( expected.sort() ) );
          checks.push( test.identical( files.sort(), expected.sort() ) );
        }
      }

      info.passed = true;
      checks.forEach( ( check ) => { info.passed &= check; } )
      testsInfo.push( info );
    })
  }

  var allFiles =  prepareTree( 1 );

  /**/

  var complexGlobs =
  [
    '**/a/a.?',
    '**/b/a.??',
    // '**/c/{x.*, c.*}', // not supported
    // 'a/**/c/{x.*, c.*}', // not supported
    // '**/b/{x, c}/*', // not supported
    '**/[!ab]/*.?s',
    'b/[a-c]/**/a/*',
    '[ab]/**/[!ac]/*',
  ]

  complexGlobs.forEach( ( glob ) =>
  {
    var o =
    {
      outputFormat : 'absolute',
      recursive : 2,
      includingTerminals : 1,
      includingTransient : 0,
      filePath : path.join( routinePath, glob ),
      filter :
      {
        basePath : routinePath,
        prefixPath : routinePath
      }
    };

    _.mapSupplement( o, fixedOptions );

    var info = _.cloneJust( o );
    info.level = levels;
    info.number = ++n;
    test.case = _.toStr( info, { levels : 3 } )
    var files = provider.filesFind( _.cloneJust( o ) );

    // var tester = path.globRegexpsForTerminal( glob, routinePath, info.filter.basePath );
    var tester = path.globsFullToRegexps( glob, routinePath, info.filter.basePath, true ).actual;

    var expected = allFiles.slice();
    expected = expected.filter( ( p ) =>
    {
      return tester.test( './' + path.relative( routinePath, p ) )
    });
    logger.log( 'Got: ', _.toStr( files ) );
    logger.log( 'Expected: ', _.toStr( expected ) );
    var checks = [];
    checks.push( test.identical( files.sort(), expected.sort() ) );

    info.passed = true;
    checks.forEach( ( check ) => { info.passed &= check; } )
    testsInfo.push( info );
  })

  drawInfo( testsInfo );

  /* - */

  function drawInfo( info )
  {
    var test = [];

    info.forEach( ( i ) =>
    {
      test.push
      ([
        i.number,
        i.level,
        i.outputFormat,
        !!i.recursive,
        !!i.includingTerminals,
        !!i.includingTransient,
        i.glob || '-',
        !!i.passed
      ])
    })

    var o =
    {
      data : test,
      head : [ '#', 'level', 'outputFormat', 'recursive', 'i.terminals', 'i.dirs', 'glob', 'passed' ],
      colWidths :
      {
        0 : 4,
        1 : 4,
      },
      colWidth : 10
    }

    var output = _.strTable( o );
    console.log( output );
  }

  /* - */

  function prepareFiles( level )
  {
    if( provider.statResolvedRead( routinePath ) )
    provider.filesDelete( routinePath );

    var dirForFile = routinePath;
    for( var i = 0; i <= level; i++ )
    {
      if( i >= 1 )
      dirForFile = path.join( dirForFile, '' + i );

      for( var j = 0; j < filesNames.length; j++ )
      {
        let terminalPath = path.join( dirForFile, filesNames[ j ] );
        provider.fileWrite( terminalPath, '' );
      }

    }

  }

  /* - */

  function makeExpected( level, o )
  {
    var expected = [];
    var dirPath = routinePath;
    var isDir = provider.isDir( o.filePath );

    if( isDir && o._includingDirs && o.includingStem )
    {
      if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
      _.arrayPrependOnce( expected, o.filePath );

      if( o.outputFormat === 'relative' )
      _.arrayPrependOnce( expected, path.relative( o.filePath, o.filePath ) );
    }

    if( !isDir )
    {
      if( o.includingTerminals )
      {
        var relative = path.dot( path.relative( o.basePath || o.filePath, o.filePath ) );
        var passed = true;

        if( o.glob )
        {
          if( relative === '.' )
          var toTest = path.dot( path.name({ path : o.filePath, full : 1 }) );
          else
          var toTest = relative;

          // var passed = path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath ).test( toTest );
          var passed = path.globsFullToRegexps( o.glob, o.filePath, o.basePath ).actual.test( toTest );
        }

        if( !passed )
        return expected;

        if( o.outputFormat === 'absolute' ||  o.outputFormat === 'record' )
        {
          expected.push( o.filePath );
        }
        if( o.outputFormat === 'relative' )
        {
          expected.push( relative );
        }
      }

      return expected;
    }

    for( var l = 0; l <= level; l++ )
    {
      var passed = true;

      if( l > 0 )
      {
        dirPath = path.join( dirPath, '' + l );
        if( o.includingDirs && o.includingTransient )
        {
          var relative = path.dot( path.relative( o.basePath || routinePath, dirPath ) );

          if( o.glob )
          passed = path.globRegexpsForDirectory( o.glob, o.filePath, o.basePath ).test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( dirPath );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        }
      }

      if( !o.recursive )
      break;

      if( o.includingTerminals )
      {

        filesNames.forEach( ( name ) =>
        {
          var terminalPath = path.join( dirPath, name );
          var passed = true;
          var relative = path.dot( path.relative( o.basePath || routinePath, terminalPath ) );

          // if( o.glob )
          // passed = path.globRegexpsForTerminal( o.glob, o.filePath, o.basePath || routinePath ).test( relative );
          if( o.glob )
          passed = path.globsFullToRegexps( o.glob, o.filePath, o.basePath || routinePath, true ).actual.test( relative );

          if( passed )
          {
            if( o.outputFormat === 'absolute' || o.outputFormat === 'record' )
            expected.push( terminalPath );
            if( o.outputFormat === 'relative' )
            expected.push( relative );
          }
        })
      }

      if( o.recursive === 1 && l === 0  )
      break;
    }

    return expected;
  }

  /* - */

  function prepareTree( numberOfDuplicates )
  {
    var part =
    {
      'a' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      },
      'b' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      },
      'c' :
      {
        'a' : {  },
        'b' : {  },
        'c' : {  },
      }
    }
    var tree =
    {
      'a' :
      {
        'a' : _.cloneJust( part ),
        'b' : _.cloneJust( part ),
        'c' : _.cloneJust( part ),
      }
    }

    provider.filesDelete( routinePath );

    for( var i = 0; i < numberOfDuplicates; i++ )
    {
      var keys = _.mapOwnKeys( tree );
      var key = keys.pop();
      tree[ String.fromCharCode( key.charCodeAt(0) + 1 ) ] = _.cloneJust( tree[ key ] );
    }

    var paths = [];
    var filesNames =
    [
      'a.js', 'a.ss', 'a.s',
    ];

    function makePaths( test, _path )
    {
      var keys = _.mapOwnKeys( test );
      keys.forEach( ( key ) =>
      {
        if( _.objectIs( test[ key ] ) )
        {
          var terminalPath = path.join( _path, key );
          filesNames.forEach( ( n ) =>
          {
            paths.push( path.join( terminalPath, n ) );
          })
          makePaths( test[ key ], terminalPath );
        }
      })
    }
    makePaths( tree , routinePath );
    paths.sort();
    paths.forEach( ( p ) => provider.fileWrite( p, '' ) )
    return paths;
  }

}

filesFind.timeOut = 60000;

//

function filesFind2( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  var terminalPath, got, expected;

  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  provider.filesDelete( routinePath );

  _.FileProvider.Extract({ filesTree }).filesReflectTo
  ({
    dst : routinePath,
    dstProvider : provider
  })

  function check( got, expected )
  {
    for( var i = 0; i < got.length; i++ )
    {
      if( _.routineIs( expected ) )
      {
        if( !expected( got[ i ] ) )
        return false;
      }
      else
      {
        if( expected.indexOf( got[ i ].fullName || got[ i ] ) === -1 )
        return false;
      }
    }

    return true;
  }

  /* - */

  function _orderingExclusion( src, orderingExclusion  )
  {
    var result = [];
    orderingExclusion = _.RegexpObject.Order( orderingExclusion );
    for( var i = 0; i < orderingExclusion.length; i++ )
    {
      for( var j = 0; j < src.length; j++ )
      {
        if( _.RegexpObject.Test( orderingExclusion[ i ], src[ j ]  ) )
        if( _.arrayRightIndex( result, src[ j ] ) >= 0 )
        continue;
        else
        result.push( src[ j ] );
      }
    }
    return result;
  }

  /* - */

  test.description = 'default options';

  /*terminalPath - directory*/

  got = provider.filesFind( routinePath );
  expected = provider.dirRead( routinePath );
  test.identical( check( got, expected ), true );

  /*terminalPath - terminal file*/

  terminalPath = path.join( routinePath, 'terminal' );
  provider.fileWrite( terminalPath, 'terminal' );
  got = provider.filesFind( terminalPath );
  expected = provider.dirRead( terminalPath );
  test.identical( check( got, expected ), true );

  /*terminalPath - empty dir*/

  terminalPath = path.join( context.testSuitePath, 'tmp/empty' );
  provider.dirMake( terminalPath )
  got = provider.filesFind( terminalPath );
  test.identical( got, [] );

  /* - */

  test.description = 'allowingMissed option';
  terminalPath = path.join( routinePath, 'terminal' );
  var nonexistentPath = path.join( routinePath, 'nonexistent' );

  /*terminalPath - relative path*/
  test.shouldThrowErrorSync( function()
  {
    provider.filesFind
    ({
      filePath : path.relative( routinePath, nonexistentPath ),
      ignoringignoringNonexistent : 0
    });
  })

  test.case = 'terminalPath - not exist, mandatory : 1';

  got = provider.filesFind
  ({
    filePath : nonexistentPath,
    allowingMissed : 1,
  });
  var expected = [];
  test.identical( got, expected );

  test.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : nonexistentPath,
      allowingMissed : 0,
      mandatory : 1,
    });
  })

  test.case = 'terminalPath - not exist, mandatory : 0';

  var expected = [];
  got = provider.filesFind
  ({
    filePath : nonexistentPath,
    allowingMissed : 0,
    mandatory : 0,
  });
  test.identical( got, expected );

  test.case = 'terminalPath - some paths dont exist, mandatory : 1';

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, terminalPath ],
    allowingMissed : 1,
  });
  expected = provider.dirRead( terminalPath );
  test.identical( check( got, expected ), true )

  test.shouldThrowErrorSync( function()
  {
    got = provider.filesFind
    ({
      filePath : [ nonexistentPath, terminalPath ],
      allowingMissed : 0,
      mandatory : 1,
    });
  });

  test.case = 'terminalPath - some paths dont exist, mandatory : 0';

  var expected = [ '.' ]
  var got = provider.filesFind
  ({
    filePath : [ nonexistentPath, terminalPath ],
    allowingMissed : 0,
    mandatory : 0,
    outputFormat : 'relative',
  });
  test.identical( got, expected );

  /*terminalPath - some paths not exist, allowingMissed on*/

  got = provider.filesFind
  ({
    filePath : [ nonexistentPath, terminalPath ],
    allowingMissed : 1,
  });
  test.identical( got.length, 1 );
  test.is( got[ 0 ] instanceof _.FileRecord );
  test.identical( got[ 0 ].fullName, 'terminal' );

  /* */

  test.description = 'includingTerminals, includingTransient options';

  /*terminalPath - empty dir, includingTerminals, includingTransient on*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( routinePath, 'empty' ), includingTerminals : 1, includingTransient : 1, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - empty dir, includingTerminals, includingTransient on, includingStem off*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( routinePath, 'empty' ), includingTerminals : 1, includingTransient : 1, includingStem : 0, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - empty dir, includingTerminals, includingTransient off*/

  provider.dirMake( path.join( context.testSuitePath, 'empty' ) )
  got = provider.filesFind({ filePath : path.join( routinePath, 'empty' ), includingTerminals : 0, includingTransient : 0, allowingMissed : 1 });
  test.identical( got, [] );

  /*terminalPath - directory, includingTerminals, includingTransient on*/

  got = provider.filesFind({ filePath : routinePath, includingTerminals : 1, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( routinePath );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, includingTerminals, includingTransient off*/

  got = provider.filesFind({ filePath : routinePath, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( routinePath );
  test.identical( got, [] );

  /*terminalPath - directory, includingTerminals off, includingTransient on*/

  got = provider.filesFind({ filePath : routinePath, includingTerminals : 0, includingTransient : 1, includingStem : 0 });
  expected = provider.dirRead( routinePath );
  test.identical( check( got, expected ), true  );

  /*terminalPath - terminal file, includingTerminals, includingTransient off*/

  terminalPath = path.join( routinePath, 'terminal' );
  got = provider.filesFind({ filePath : terminalPath, includingTerminals : 0, includingTransient : 0 });
  expected = provider.dirRead( routinePath );
  test.identical( got, [] );

  /*terminalPath - terminal file, includingTerminals off, includingTransient on*/

  terminalPath = path.join( routinePath, 'terminal' );
  got = provider.filesFind({ filePath : terminalPath, includingTerminals : 0, includingTransient : 1 });
  test.identical( got, [] );

  //

  test.description = 'outputFormat option';

  /*terminalPath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : routinePath, outputFormat : 'record' });
  function recordIs( element ){ return element.constructor.name === 'wFileRecord' };
  expected = provider.dirRead( routinePath );
  test.identical( check( got, recordIs ), true );

  /*terminalPath - directory, outputFormat absolute */

  got = provider.filesFind({ filePath : routinePath, outputFormat : 'absolute' });
  expected = provider.dirRead( routinePath );
  // test.identical( check( got, path.isAbsolute ), true );
  test.identical( path.s.allAreAbsolute( got ), true );

  /*terminalPath - directory, outputFormat relative */

  got = provider.filesFind({ filePath : routinePath, outputFormat : 'relative' });
  expected = provider.dirRead( routinePath );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = path.join( './', expected[ i ] );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, outputFormat nothing */

  got = provider.filesFind({ filePath : routinePath, outputFormat : 'nothing' });
  test.identical( got, [] );

  /*terminalPath - directory, outputFormat unexpected */

  test.shouldThrowErrorSync( function()
  {
    provider.filesFind({ filePath : routinePath, outputFormat : 'unexpected' });
  })

  //

  test.description = 'result option';

  /*terminalPath - directory, result not empty array, all existing files must be skipped*/

  expected = provider.filesFind({ filePath : routinePath, result : got });
  test.identical( got.length, expected.length );
  test.is( got === expected );

  /*terminalPath - directory, result empty array*/

  got = [];
  provider.filesFind({ filePath : routinePath, result : got });
  expected = provider.dirRead( routinePath );
  test.identical( check( got, expected ), true );

  /*terminalPath - directory, result object without push function*/

  test.shouldThrowErrorSync( function()
  {
    got = {};
    provider.filesFind({ filePath : routinePath, result : got });
  });

  //

  test.description = 'masking'

  /*terminalPath - directory, maskTerminal, get all files with 'Files' in name*/

  got = provider.filesFind
  ({
    filePath : routinePath,
    filter :
    {
      maskTerminal : 'Files',
    },
    outputFormat : 'relative'
  });
  expected = provider.dirRead( routinePath );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.Test( 'Files', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected );

  /* terminalPath - directory, maskDirectory, includingTransient */

  terminalPath = path.join( context.testSuitePath, 'tmp/dir' );
  provider.dirMake( terminalPath );

  got = provider.filesFind
  ({
    filePath : terminalPath,
    filter :
    {
      basePath : path.dir( terminalPath ),
      maskDirectory : 'dir',
    },
    outputFormat : 'relative',
    includingStem : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2
  });
  expected = provider.dirRead( path.dir( terminalPath ) );
  expected = expected.filter( function( element )
  {
    return _.RegexpObject.Test( 'dir', element  );
  });
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected );

  /*terminalPath - directory, maskAll with some random expression, no result expected */

  got = provider.filesFind
  ({
    filePath : routinePath,
    filter :
    {
      maskAll : 'a12b',
    }
  });
  test.identical( got, [] );

  /*terminalPath - directory, orderingExclusion mask, maskTerminal null, expected order Caching->terminals*/

  var orderingExclusion = [ 'src', 'dir3' ];
  got = provider.filesFind
  ({
    filePath : routinePath,
    orderingExclusion : orderingExclusion,
    includingDirs : 1,
    recursive : 1,
    outputFormat : 'record'
  });
  got = got.map( ( r ) => r.relative );
  expected = _orderingExclusion( provider.dirRead( routinePath ), orderingExclusion );
  for( var i = 0; i < expected.length; ++i )
  expected[ i ] = './' + expected[ i ];
  test.identical( got, expected )

  //

  test.description = 'change relative path in record';

  /*change relative to wFiles, relative should be like ./staging/dwtools/amid/files/z.test/'file_name'*/

  var relative = path.join( routinePath, 'src' );
  got = provider.filesFind
  ({
    filePath : path.join( routinePath, 'src/dir' ),
    filter : { basePath : relative },
    recursive : 1
  });
  got = got[ 0 ].relative;
  var begins = './' + path.relative( relative, path.join( routinePath, 'src/dir' ) );
  test.identical( _.strBegins( got, begins ), true );

  /* changing relative path affects only record.relative*/

  got = provider.filesFind
  ({
    filePath : routinePath,
    filter :
    {
      basePath : '/x/a/b',
    },
    recursive : 2,
    maskPreset : 0,
  });

  test.identical( _.strBegins( got[ 0 ].absolute, '/x' ), false );
  test.identical( _.strBegins( got[ 0 ].real, '/x' ), false );
  test.identical( _.strBegins( got[ 0 ].dir, '/x' ), false );

  /* - */

  test.description = 'etc';

  /*strict mode on - prevents extension of wFileRecord*/

  test.shouldThrowErrorSync( function()
  {
    var records = provider.filesFind( routinePath );
    records[ 0 ].newProperty = 1;
  })

  /*strict mode off */

  // test.mustNotThrowError( function()
  // {
  //   var records = provider.filesFind({ filePath : dir/*, strict : 0*/ });
  //   records[ 0 ].newProperty = 1;
  // })

}

//

function filesFindRecursive( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var extract = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', dir : { a1 : '1' } },
      src2 : { ax2 : '20', dirx : { a : '20' } },
    },
  });

  extract.filesReflectTo( provider, routinePath );

  /**/

  test.open( 'directory' );

  var got = provider.filesFind
  ({
    filePath : routinePath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 0,
  })
  test.identical( got, [ '.' ] )

  var got = provider.filesFind
  ({
    filePath : routinePath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 1,
  })
  var expected = [ '.', './src', './src2' ]
  test.identical( got, expected );

  var got = provider.filesFind
  ({
    filePath : routinePath,
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 2,
  })
  var expected = [ '.', './src', './src/a1', './src/dir', './src/dir/a1', './src2', './src2/ax2', './src2/dirx', './src2/dirx/a' ]
  test.identical( got, expected );

  test.close( 'directory' );

  /* */

  test.open( 'terminal' );

  var got = provider.filesFind
  ({
    filePath : path.join( routinePath, './src/a1' ),
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : path.join( routinePath, './src' ) },
    recursive : 0,
  })
  var expected = [ './a1' ]

  var got = provider.filesFind
  ({
    filePath : abs( './src/a1' ),
    filter : { basePath : abs( './src' ) },
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    recursive : 1,
  })
  var expected = [ './a1' ]
  test.identical( got, expected );

  //

  var got = provider.filesFind
  ({
    filePath : path.join( routinePath, './src/a1' ),
    includingDirs : 1,
    includingTerminals : 1,
    includingTransient : 1,
    outputFormat : 'relative',
    filter : { basePath : path.join( routinePath, './src' ) },
    recursive : 2,
  })
  var expected = [ './a1' ]
  test.identical( got, expected );

  test.close( 'terminal' );

  /* */

  if( !Config.debug )
  return;

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '0',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '1',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '2',
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : true,
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : false,
    })
  })

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : path.join( routinePath ),
      includingDirs : 1,
      includingTerminals : 1,
      includingTransient : 1,
      outputFormat : 'relative',
      recursive : '0',
    })
  })
}

filesFindRecursive.timeOut = 15000;

//

function filesFindLinked( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /*
    link : [ normal, double, broken, context cycled, cycled, dst and src resolving to the same file ]
  */

  /**/

  function select( container, path )
  {
    let result = _.select( container, path );
    if( _.strIs( result[ 0 ] ) )
    result = result.map( ( e ) => _.strPrependOnce( _.strRemoveBegin( e, routinePath ), '/' ) );
    return result;
  }

  /**/

  let terminalPath = path.join( routinePath, 'terminal' );
  let normalPath = path.join( routinePath, 'normal' );
  let doublePath = path.join( routinePath, 'double' );
  let brokenPath = path.join( routinePath, 'broken' );
  let missingPath = path.join( routinePath, 'missing' );
  let autoPath = path.join( routinePath, 'auto' );
  let onePath = path.join( routinePath, 'one' );
  let twoPath = path.join( routinePath, 'two' );
  let normalaPath = path.join( routinePath, 'normala' );
  let normalbPath = path.join( routinePath, 'normalb' );
  let dirPath = path.join( routinePath, 'directory' );
  let toDirPath = path.join( routinePath, 'toDir' );

  //

  test.open( 'normal' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normal', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  console.log( got[ 1 ].real );

  test.identical( select( got, '*/absolute' ), [ '/', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal' ] );

  test.close( 'normal' );

  /* */

  test.open( 'double' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    double : [{ softLink : '/normal' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink( doublePath, normalPath );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/double', '/normal', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/double', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'double' );

  /* */

  test.open( 'broken' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    broken : [{ softLink : '/missing' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink({ dstPath : brokenPath, srcPath : missingPath, allowingMissed : 1 });

  test.case = 'resolvingSoftLink : 0, allowingMissed : 0, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 0,
    allowingMissed : 0,
    allowingCycled : 0,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  test.case = 'resolvingSoftLink : 1, allowingMissed : 1, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    includingDefunct : 1,
    recursive : 2,
    resolvingSoftLink : 1,
    allowingMissed : 1,
    allowingCycled : 0,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/broken', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/missing', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, false, true, true ] );

  test.case = 'resolvingSoftLink : 1, allowingMissed : 0, allowingCycled : 1';

  test.shouldThrowErrorSync( () =>
  {
    var got = context.provider.filesFind
    ({
      filePath : routinePath,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      includingDirs : 1,
      includingStem : 1,
      recursive : 2,
      resolvingSoftLink : 1,
      allowingMissed : 0,
      allowingCycled : 1,
      once : 0,
    })
  });

  test.close( 'broken' );

  /* */

  test.open( 'context cycled' );

  var tree =
  {
    terminal : 'terminal',
    normal : [{ softLink : '/terminal' }],
    auto : [{ softLink : '/auto' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalPath, terminalPath );
  context.provider.softLink({ dstPath : autoPath, srcPath : '../auto', allowingMissed : 1 });

  /* */

  test.case = 'resolvingSoftLink : 0, allowingMissed : 0, allowingCycled : 0';

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 0,
    allowingMissed : 0,
    allowingCycled : 0,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  /* */

  test.case = 'resolvingSoftLink : 1, allowingMissed : 0, allowingCycled : 1';

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    resolvingSoftLink : 1,
    allowingMissed : 0,
    allowingCycled : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/auto', '/normal', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/auto', '/terminal', '/terminal' ] );
  test.identical( select( got, '*/stat' ).map( ( e ) => !!e ), [ true, true, true, true ] );

  /* */

  test.case = 'resolvingSoftLink : 1, allowingMissed : 1, allowingCycled : 0';

  test.shouldThrowErrorSync( () =>
  {
    var got = context.provider.filesFind
    ({
      filePath : routinePath,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      includingDirs : 1,
      includingStem : 1,
      recursive : 2,
      resolvingSoftLink : 1,
      allowingMissed : 1,
      allowingCycled : 0,
      once : 0,
    })
  });

  test.close( 'context cycled' );

  /* */

  test.open( 'cycled' );

  var tree =
  {
    terminal : 'terminal',
    one : [{ softLink : '/two' }],
    two : [{ softLink : '/one' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink({ dstPath : twoPath, srcPath : onePath, allowingMissed : 1 });
  context.provider.softLink({ dstPath : onePath, srcPath : twoPath, allowingMissed : 1 });

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 0,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.shouldThrowError( () =>
  {
    provider.filesFind
    ({
      filePath : routinePath,
      resolvingSoftLink : 1,
      outputFormat : 'record',
      includingTransient : 1,
      includingTerminals : 1,
      allowingMissed : 0,
      includingDirs : 1,
      recursive : 2,
      includingStem : 1,
      once : 0,
    })
  })

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    allowingMissed : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/one', '/terminal', '/two' ] );
  test.identical( select( got, '*/real' ), [ '/', '/one', '/terminal', '/two' ] );

  test.close( 'cycled' );

  /**/

  test.open( 'links to same file' );

  var tree =
  {
    terminal : 'terminal',
    normala : [{ softLink : '/terminal' }],
    normalb : [{ softLink : '/terminal' }],
  }

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalPath, terminalPath );
  context.provider.softLink( normalaPath, terminalPath );
  context.provider.softLink( normalbPath, terminalPath );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/normala', '/normalb', '/terminal' ] );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/normala', '/normalb', '/terminal' ] );
  test.identical( select( got, '*/real' ), [ '/', '/terminal', '/terminal', '/terminal' ] );

  test.close( 'links to same file' );

  /**/

  test.open( 'link to directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal',
    },
    toDir : [{ softLink : '/directory' }],
  }

  var terminalInDirPath = context.provider.path.join( dirPath, 'terminal' );

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  context.provider.softLink( toDirPath, dirPath );

  var got = context.provider.filesFind
  ({
    filePath : toDirPath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir'  ] );
  test.identical( select( got, '*/real' ), [ '/toDir' ] );

  var got = context.provider.filesFind
  ({
    filePath : toDirPath,
    outputFormat : 'record',
    resolvingSoftLink : 1,
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    includingStem : 1,
    recursive : 2,
    once : 0,
  })

  test.identical( select( got, '*/absolute' ), [ '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/directory', '/directory/terminal'  ] );

  test.close( 'link to directory' );

  /**/

  test.open( 'link to processed directory' );

  var tree =
  {
    directory :
    {
      terminal : 'terminal'
    },
    toDir : [{ softLink : '/directory'}]
  }

  var terminalInDirPath = context.provider.path.join( dirPath, 'terminal' );

  context.provider.filesDelete( routinePath );
  context.provider.fileWrite( terminalInDirPath, terminalInDirPath );
  context.provider.softLink( toDirPath, dirPath );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 0,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })

  test.identical( select( got, '*/absolute' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/toDir', '/directory', '/directory/terminal'  ] );

  var got = context.provider.filesFind
  ({
    filePath : routinePath,
    resolvingSoftLink : 1,
    outputFormat : 'record',
    includingTransient : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    includingStem : 1,
    once : 0,
  })
  test.identical( select( got, '*/absolute' ), [ '/', '/directory', '/directory/terminal', '/toDir', '/toDir/terminal'  ] );
  test.identical( select( got, '*/real' ), [ '/', '/directory', '/directory/terminal', '/directory', '/directory/terminal'  ] );

  test.close( 'link to processed directory' );

} /* end of filesFindLinked */

//

function filesFindSoftLinksExtract( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  function rel()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.relative.apply( path.s, args );
  }

  /* - */

  test.open( 'absolute links' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once off';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/file1',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dir1/dir2',
    './dirLink2/file1 - /src/proto/dirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink2/file2 - /src/proto/dirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file1 - /src/proto/dirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1',
    './dirLink3/dir4/dirLink - /src/proto/dirLink3/dir4/dirLink - /src/proto/dir1',
    './dirLink3/dir4/dirLink/dir2 - /src/proto/dirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 0,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'absolute links' );

  test.open( 'relative links' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once off';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/file1',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dir1/dir2',
    './dirLink2/file1 - /src/proto/dirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink2/file2 - /src/proto/dirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file1 - /src/proto/dirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1',
    './dirLink3/dir4/dirLink - /src/proto/dirLink3/dir4/dirLink - /src/proto/dir1',
    './dirLink3/dir4/dirLink/dir2 - /src/proto/dirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 0,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'relative links' );

  test.open( 'absolute links, double' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dualDirLink2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto/dualDirLink3',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dualDirLink4',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/dualTerLink1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto/dualTerLink2',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once off';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/file1',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dir1/dir2',
    './dirLink2/file1 - /src/proto/dirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink2/file2 - /src/proto/dirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file1 - /src/proto/dirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1',
    './dirLink3/dir4/dirLink - /src/proto/dirLink3/dir4/dirLink - /src/proto/dir1',
    './dirLink3/dir4/dirLink/dir2 - /src/proto/dirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dir1/dir2',
    './dualDirLink2/file1 - /src/proto/dualDirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink2/file2 - /src/proto/dualDirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto2/dir3',
    './dualDirLink3/dir4 - /src/proto/dualDirLink3/dir4 - /src/proto2/dir3/dir4',
    './dualDirLink3/dir4/file1 - /src/proto/dualDirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dualDirLink3/dir4/file2 - /src/proto/dualDirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dualDirLink3/dir4/terLink - /src/proto/dualDirLink3/dir4/terLink - /src/proto2/file1',
    './dualDirLink3/dir4/dirLink - /src/proto/dualDirLink3/dir4/dirLink - /src/proto/dir1',
    './dualDirLink3/dir4/dirLink/dir2 - /src/proto/dualDirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dualDirLink3/dir4/dirLink/dir2/file1 - /src/proto/dualDirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink3/dir4/dirLink/dir2/file2 - /src/proto/dualDirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dir1',
    './dualDirLink4/dir2 - /src/proto/dualDirLink4/dir2 - /src/proto/dir1/dir2',
    './dualDirLink4/dir2/file1 - /src/proto/dualDirLink4/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink4/dir2/file2 - /src/proto/dualDirLink4/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 0,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'absolute links, double' );

  test.open( 'relative links, double' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dualDirLink2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto/dualDirLink3',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dualDirLink4',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/dualTerLink1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto/dualTerLink2',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once off';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/file1',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dir1/dir2',
    './dirLink2/file1 - /src/proto/dirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink2/file2 - /src/proto/dirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file1 - /src/proto/dirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dirLink3/dir4/terLink - /src/proto/dirLink3/dir4/terLink - /src/proto2/file1',
    './dirLink3/dir4/dirLink - /src/proto/dirLink3/dir4/dirLink - /src/proto/dir1',
    './dirLink3/dir4/dirLink/dir2 - /src/proto/dirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dir1/dir2',
    './dualDirLink2/file1 - /src/proto/dualDirLink2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink2/file2 - /src/proto/dualDirLink2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto2/dir3',
    './dualDirLink3/dir4 - /src/proto/dualDirLink3/dir4 - /src/proto2/dir3/dir4',
    './dualDirLink3/dir4/file1 - /src/proto/dualDirLink3/dir4/file1 - /src/proto2/dir3/dir4/file1',
    './dualDirLink3/dir4/file2 - /src/proto/dualDirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2',
    './dualDirLink3/dir4/terLink - /src/proto/dualDirLink3/dir4/terLink - /src/proto2/file1',
    './dualDirLink3/dir4/dirLink - /src/proto/dualDirLink3/dir4/dirLink - /src/proto/dir1',
    './dualDirLink3/dir4/dirLink/dir2 - /src/proto/dualDirLink3/dir4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dualDirLink3/dir4/dirLink/dir2/file1 - /src/proto/dualDirLink3/dir4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink3/dir4/dirLink/dir2/file2 - /src/proto/dualDirLink3/dir4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto2/dir3/dir4',
    './dualDirLink4/file1 - /src/proto/dualDirLink4/file1 - /src/proto2/dir3/dir4/file1',
    './dualDirLink4/file2 - /src/proto/dualDirLink4/file2 - /src/proto2/dir3/dir4/file2',
    './dualDirLink4/terLink - /src/proto/dualDirLink4/terLink - /src/proto2/file1',
    './dualDirLink4/dirLink - /src/proto/dualDirLink4/dirLink - /src/proto/dir1',
    './dualDirLink4/dirLink/dir2 - /src/proto/dualDirLink4/dirLink/dir2 - /src/proto/dir1/dir2',
    './dualDirLink4/dirLink/dir2/file1 - /src/proto/dualDirLink4/dirLink/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dualDirLink4/dirLink/dir2/file2 - /src/proto/dualDirLink4/dirLink/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 0,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on, once on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'relative links, double' );
  test.open( 'absolute links, loops' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink1 - /src/proto/dirLink1 - /src/proto/dirLink1',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './dualDirLink1 - /src/proto/dualDirLink1 - /src/proto/dualDirLink1',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dualDirLink2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto/dualDirLink3',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dualDirLink4',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/dualTerLink1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto/dualTerLink2',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'absolute links, loops' );
  test.open( 'relative links, loops' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var find = extract.filesFinder
  ({
    filePath : '/src/proto',
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink1 - /src/proto/dirLink1 - /src/proto/dirLink1',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './dualDirLink1 - /src/proto/dualDirLink1 - /src/proto/dualDirLink1',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dualDirLink2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto/dualDirLink3',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dualDirLink4',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/dualTerLink1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto/dualTerLink2',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    once : 0
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'relative links, loops' );

  /* - */

} /* end of filesFindSoftLinksExtract */

//

function filesFindSoftLinks( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  function rel()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.relative.apply( path.s, args );
  }

  test.open( 'relative links, loops' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  debugger;
  extract.filesReflectTo
  ({
    dstProvider : provider,
    dst : routinePath,
    resolvingSrcSoftLink : 0,
  });
  debugger;
  var find = provider.filesFinder
  ({
    filePath : abs( 'src/proto' ),
    includingDirs : 1,
    recursive : 2,
  });

  /* */

  test.case = 'default resolving';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dirLink1 - /src/proto/dirLink1 - /src/proto/dirLink1',
    './dirLink2 - /src/proto/dirLink2 - /src/proto/dirLink2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto/dirLink3',
    './dualDirLink1 - /src/proto/dualDirLink1 - /src/proto/dualDirLink1',
    './dualDirLink2 - /src/proto/dualDirLink2 - /src/proto/dualDirLink2',
    './dualDirLink3 - /src/proto/dualDirLink3 - /src/proto/dualDirLink3',
    './dualDirLink4 - /src/proto/dualDirLink4 - /src/proto/dualDirLink4',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/dualTerLink1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto/dualTerLink2',
    './file1 - /src/proto/file1 - /src/proto/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink1 - /src/proto/terLink1 - /src/proto/terLink1',
    './terLink2 - /src/proto/terLink2 - /src/proto/terLink2',
    './terLink3 - /src/proto/terLink3 - /src/proto/terLink3',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file1 - /src/proto/dir1/dir2/file1 - /src/proto/dir1/dir2/file1',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2'
  ]
  var got = find
  ({
    once : 0
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* */

  test.case = 'resolving on';
  var expected =
  [
    '. - /src/proto - /src/proto',
    './dualTerLink1 - /src/proto/dualTerLink1 - /src/proto/file1',
    './dualTerLink2 - /src/proto/dualTerLink2 - /src/proto2/file1',
    './file2 - /src/proto/file2 - /src/proto/file2',
    './terLink2 - /src/proto/terLink2 - /src/proto/dir1/dir2/file1',
    './terLink3 - /src/proto/terLink3 - /src/proto2/dir3/dir4/file1',
    './dir1 - /src/proto/dir1 - /src/proto/dir1',
    './dir1/dir2 - /src/proto/dir1/dir2 - /src/proto/dir1/dir2',
    './dir1/dir2/file2 - /src/proto/dir1/dir2/file2 - /src/proto/dir1/dir2/file2',
    './dirLink3 - /src/proto/dirLink3 - /src/proto2/dir3',
    './dirLink3/dir4 - /src/proto/dirLink3/dir4 - /src/proto2/dir3/dir4',
    './dirLink3/dir4/file2 - /src/proto/dirLink3/dir4/file2 - /src/proto2/dir3/dir4/file2'
  ]
  var got = find
  ({
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
    once : 1,
  });
  got = got.map( ( r ) => `${r.relative} - ${r.absolute} - ${r.real}` );
  test.identical( got, expected );

  /* - */

  test.close( 'relative links, loops' );

  /* - */

  debugger; return; xxx
} /* end of filesFindSoftLinks */

//

function filesFindResolving( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let terminalPath = path.join( routinePath, 'terminal' );
  let softLinkIsSupported = context.softLinkIsSupported();

  var fixedOptions =
  {
    allowingMissed : 1,
    orderingExclusion : [],
    sortingWithArray : null,
    outputFormat : 'record',
    includingStem : 1,
    includingTerminals : 1,
    includingTransient : 1,
    includingDirs : 1,
    recursive : 2,
    once : 0,
  }

  function recordSimplify( record )
  {
    var result =
    {
      absolute : record.absolute,
      real : record.real,
      isDir : record.isDir
    }

    return result;
  }

  function findRecord( records, field, value )
  {
    var result = records.filter( ( r ) =>
    {
      if( r[ field ] === value )
      return r;
    });

    _.assert( result.length === 1 );

    return result[ 0 ];
  }

  /*

    resolvingSoftLink : 0, 1
    resolvingTextLink : 0, 1
    provider : usingTextLink : 0, 1

  */

  //

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 0 );

  //

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 0';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : textLinkPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );


  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 0';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 0 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : textLinkPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.is( srcFileStat.ino !== textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 0, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected );
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

   //

  test.case = 'text link to a file, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'text->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  var textLink2Path = path.join( routinePath, 'textLink2' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  provider.fileWrite( textLink2Path, 'link ' + srcFilePath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLink2Path,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var textLink2Stat = findRecord( files, 'absolute', textLink2Path ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, textLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  if( !softLinkIsSupported )
  return;

  /* soft link */

  test.case = 'soft link to a file, resolvingSoftLink : 0, resolvingTextLink : 0'
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
  }
  var o2 = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( routinePath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( o2 );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true,
    },
    {
      absolute : softLink,
      real : softLink,
      isDir : false,
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false,
    }
  ]
  test.identical( filtered, expected );
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.is( srcFileStat.ino !== softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( routinePath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]
  test.identical( filtered, expected );
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a file, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( routinePath, 'link' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 0';
  var srcDirPath = path.join( routinePath, 'dir' );
  var softLink = path.join( routinePath, 'linkToDir' );
  provider.fieldPush( 'usingTextLink', 0 );
  provider.filesDelete( routinePath );
  terminalPath = path.join( srcDirPath, 'terminal' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
    includingStem : 0
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.softLink( softLink, srcDirPath );

  var files = provider.filesFind(options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLink, path.name({ path : terminalPath, full : 1 }) ),
      real : path.join( srcDirPath, path.name({ path : terminalPath, full : 1 }) ),
      isDir : false
    }
  ]

  test.identical( filtered, expected )
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'soft link to a dir, resolvingSoftLink : 1, resolvingTextLink : 1';
  var srcDirPath = path.join( routinePath, 'dir' );
  var softLink = path.join( routinePath, 'linkToDir' );
  provider.fieldPush( 'usingTextLink', 1 );
  provider.filesDelete( routinePath );
  terminalPath = path.join( srcDirPath, 'terminal' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.softLink( softLink, srcDirPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLink, path.name({ path : terminalPath, full : 1 }) ),
      real : path.join( srcDirPath, path.name({ path : terminalPath, full : 1 }) ),
      isDir : false
    }
  ]

  logger.log( _.toStr( files, { levels : 99 } )   )

  test.identical( filtered, expected )
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  test.identical( srcDirStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( routinePath );
  terminalPath = path.join( routinePath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( routinePath, 'link' );
  var softLink2 = path.join( routinePath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, softLink );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links in chain, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( routinePath );
  terminalPath = path.join( routinePath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( routinePath, 'link' );
  var softLink2 = path.join( routinePath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, softLink );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 0'
  provider.filesDelete( routinePath );
  terminalPath = path.join( routinePath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 0,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 0 );
  var softLink = path.join( routinePath, 'link' );
  var softLink2 = path.join( routinePath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 0 );

  //

  test.case = 'multiple soft links to single file, resolvingSoftLink : 1, resolvingTextLink : 1'
  provider.filesDelete( routinePath );
  terminalPath = path.join( routinePath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }

  var options = _.mapExtend( o, fixedOptions );
  provider.fieldPush( 'usingTextLink', 1 );
  var softLink = path.join( routinePath, 'link' );
  var softLink2 = path.join( routinePath, 'link2' );
  var srcPath = terminalPath;
  provider.softLink( softLink, srcPath );
  provider.softLink( softLink2, srcPath );
  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLink2,
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( terminalPath );
  var softLinkStat = findRecord( files, 'absolute', softLink ).stat;
  var softLink2Stat = findRecord( files, 'absolute', softLink2 ).stat;
  test.identical( srcFileStat.ino, softLinkStat.ino );
  test.identical( srcFileStat.ino, softLink2Stat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  //

  test.case = 'soft->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  provider.filesDelete( routinePath );
  terminalPath = path.join( routinePath, 'file' );
  provider.fileWrite( terminalPath, terminalPath );
  var srcFilePath = terminalPath;
  var textLinkPath = path.join( routinePath, 'textLink' );
  var softLinkPath = path.join( routinePath, 'softLinkPath' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcFilePath );
  provider.softLink( softLinkPath, textLinkPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcFilePath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : softLinkPath,
      real : srcFilePath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcFilePath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  var srcFileStat = provider.statResolvedRead( srcFilePath );
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcFileStat.ino, textLinkStat.ino );
  test.identical( srcFileStat.ino, softLinkStat.ino );
  provider.fieldPop( 'usingTextLink', 1 );

  /* */

  test.case = 'soft->text->terminal, resolvingSoftLink : 1, resolvingTextLink : 1, usingTextLink : 1';
  var srcDirPath = path.join( routinePath, 'dir' );
  terminalPath = path.join( srcDirPath, 'terminal' );
  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  var textLinkPath = path.join( routinePath, 'textLink' );
  var softLinkPath = path.join( routinePath, 'softLink' );
  provider.fieldPush( 'usingTextLink', 1 );
  var o =
  {
    filePath : routinePath,
    resolvingSoftLink : 1,
    resolvingTextLink : 1,
  }
  var options = _.mapExtend( o, fixedOptions );
  provider.fileWrite( textLinkPath, 'link ' + srcDirPath );
  provider.softLink( softLinkPath, textLinkPath );

  var files = provider.filesFind( options );
  var filtered = files.map( recordSimplify );
  var expected =
  [
    {
      absolute : routinePath,
      real : routinePath,
      isDir : true
    },
    {
      absolute : srcDirPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : terminalPath,
      real : terminalPath,
      isDir : false
    },
    {
      absolute : softLinkPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( softLinkPath, 'terminal' ),
      real : terminalPath,
      isDir : false
    },
    {
      absolute : textLinkPath,
      real : srcDirPath,
      isDir : true
    },
    {
      absolute : path.join( textLinkPath, 'terminal' ),
      real : terminalPath,
      isDir : false
    },
  ]

  test.identical( filtered, expected )
  console.log( _.toStr( filtered, { levels : 99 }))
  var srcDirStat = provider.statResolvedRead( srcDirPath );
  var srcFileStat = findRecord( files, 'absolute', terminalPath ).stat;
  var textLinkStat = findRecord( files, 'absolute', textLinkPath ).stat;
  var softLinkStat = findRecord( files, 'absolute', softLinkPath ).stat;
  test.identical( srcDirStat.ino, textLinkStat.ino );
  test.identical( srcDirStat.ino, softLinkStat.ino );
  test.is( srcFileStat.ino !== textLinkStat.ino )
  test.is( srcFileStat.ino !== softLinkStat.ino )
  provider.fieldPop( 'usingTextLink', 1 );

}

//

function filesFindResolvingExperiment( test )
{
  let context = this;
  let provider = context.provider;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  test.case = 'textLink->dir, resolvingTextLink : 1, usingTextLink : 1';
  let srcDirPath = path.join( routinePath, 'dir' );
  let terminalPath = path.join( srcDirPath, 'terminal' );
  let textLinkPath = path.join( routinePath, 'textLink' );

  provider.filesDelete( routinePath );
  provider.fileWrite( terminalPath, terminalPath );
  provider.fieldPush( 'usingTextLink', 1 );
  provider.textLink( textLinkPath, srcDirPath );

  var o =
  {
    filePath : textLinkPath,
    resolvingTextLink : 1,
    includingStem : 1,
    includingTerminals : 1,
    includingTransient : 1,
    includingDirs : 1,
    recursive : 2
  }

  var files = provider.filesFind( o );

  provider.fieldPop( 'usingTextLink', 1 );


}

//

function filesFindGlob( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = context.makeStandardExtract();
  src.filesReflectTo( provider, routinePath );

  function selectTransients( records )
  {
    return _.filter( records, ( record ) => record.isTransient ? record.relative : undefined );
  }

  function selectActuals( records )
  {
    return _.filter( records, ( record ) => record.isActual ? record.relative : undefined );
  }

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var globTerminals = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globAll = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globTerminalsWithPrefix = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  var globAllWithPrefix = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  /* - */

  test.case = 'globTerminals map with bools';
  var expectedRelative = [ './doubledir/a', './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var filePath = abs({ '**/d2/**' : 0, 'doubledir' : '' });
  var records = globTerminals({ filePath : filePath });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll map with bools';
  var expectedRelative = [ './doubledir', './doubledir/a', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var filePath = abs({ '**/d2/**' : 0, 'doubledir' : '' });
  var records = globAll({ filePath : filePath });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.case = 'globTerminals doubledir/*/*';
  var expectedRelative = [ './doubledir/a', './doubledir/d1/a', './doubledir/d2/b' ];
  var records = globTerminals({ filePath : abs( 'doubledir/*/*' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll doubledir/*/*';
  var expectedRelative = [ './doubledir', './doubledir/a', './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22' ];
  var records = globAll({ filePath : abs( 'doubledir/*/*' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.case = 'globTerminals src1';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals({ filePath : abs( 'src1' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1';
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll({ filePath : abs( 'src1' ) });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**, prefixPath : /src2';
  var expAbsolutes = [];
  var expIsActual = [];
  var expIsTransient = [];
  var expStat = [];
  var records = globTerminals({ filePath : 'src1/**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotIsActual = _.select( records, '*/isActual' );
  var gotIsTransient = _.select( records, '*/isTransient' );
  var gotStat = _.select( records, '*/stat' ).map( ( e ) => !!e );
  test.identical( gotRelative, expAbsolutes );
  test.identical( gotIsActual, expIsActual );
  test.identical( gotIsTransient, expIsTransient );
  test.identical( gotStat, expStat );

  test.case = 'globAll src1/**, prefixPath : /src2';
  var expectedRelative = [];
  var records = globAll({ filePath : 'src1/**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';
  var expectedRelative = [ './a', './b', './c', './d/a', './d/b', './d/c' ];
  var records = globTerminals({ filePath : './**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';
  var expectedRelative = [ '.', './a', './b', './c', './d', './d/a', './d/b', './d/c' ];
  var records = globAll({ filePath : './**', filter : { prefixPath : abs( 'src2' ), basePath : abs( 'src2' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals (src1|src2)/**';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filePath : '(src1|src2)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll (src1|src2)/**';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filePath : '(src1|src2)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src(1|2)/**';
  var expectedRelative = [ './src/f', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filePath : 'src(1|2|)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src(1|2)/**';
  var expectedRelative = [ '.', './src', './src/f', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filePath : 'src(1|2|)/**', filter : { prefixPath : abs( '.' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1**';
  var expectedRelative = [ './src1Terminal', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a' ];
  var records = globTerminals( abs( 'src1**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1**';
  var expectedRelative = [ '.', './src1Terminal', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a' ];
  var records = globAll( abs( 'src1**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1/*'; /* */
  var expectedRelative = [ './src1/a', './src1/b', './src1/c' ];
  var records = globTerminals( abs( 'src1/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/*';
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var records = globAll( abs( 'src1/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1*'; /* */
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals( abs( 'src1*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1*';
  var expectedRelative = [ '.', './src1Terminal', './src1', './src1b' ];
  var records = globAll( abs( 'src1*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src3/** - nothing'; /* */
  var expectedRelative = [];
  var records = globTerminals( abs( 'src3/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src3/** - nothing';
  var expectedRelative = [];
  var records = globAll( abs( 'src3/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src?'; /* */
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( 'src?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?';
  var expectedRelative = [ '.', './srcT', './src1', './src2' ];
  var records = globAll( abs( 'src?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src?*'; /* */
  var expectedRelative = [ './src1Terminal', './srcT' ];
  var records = globTerminals( abs( 'src?*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?*';
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( 'src?*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src*?'; /* */
  var expectedRelative = [ './src1Terminal', './srcT' ];
  var records = globTerminals( abs( 'src*?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src*?';
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( 'src*?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src**?';
  var expectedRelative = [ './src1Terminal', './srcT', './src/f', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d/a', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d/a' ];
  var records = globTerminals( abs( 'src**?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src**?';
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src', './src/f', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d', './src3.js/d/a', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d', './src3.s/d/a' ];
  var records = globAll( abs( 'src**?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src**????';
  var expectedRelative = [ './src1Terminal', './src3.js/c.js', './src3.s/c.js' ];
  var records = globTerminals( abs( 'src**????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src**????';
  var expectedRelative = [ '.', './src1Terminal', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/c.js', './src3.js/d', './src3.s', './src3.s/c.js', './src3.s/d' ];
  var records = globAll( abs( 'src**????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src**?????????';
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals( abs( 'src**?????????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src**?????????';
  var expectedRelative = [ '.', './src1Terminal', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/d', './src3.s', './src3.s/d' ];
  var records = globAll( abs( 'src**?????????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src**??????????';
  var expectedRelative = [];
  var records = globTerminals( abs( 'src**??????????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src**??????????';
  var expectedRelative = [ '.', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/d', './src3.s', './src3.s/d' ];
  var records = globAll( abs( 'src**??????????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src?**';
  var expectedRelative = [ './src1Terminal', './srcT', './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1b/a', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d/a', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d/a' ];
  var records = globTerminals( abs( 'src?**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src?**';
  var expectedRelative = [ '.', './src1Terminal', './srcT', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src1b', './src1b/a', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c', './src3.js', './src3.js/a', './src3.js/b.s', './src3.js/c.js', './src3.js/d', './src3.js/d/a', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d', './src3.s/d/a' ];
  var records = globAll( abs( 'src?**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(src)2'; /* */
  var expectedRelative = [];
  var records = globTerminals( abs( '+(src)2' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(src)2';
  var expectedRelative = [ '.', './src2' ];
  var records = globAll( abs( '+(src)2' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(alt)/*'; /* */
  var expectedRelative = [ './alt/a', './altalt/a' ];
  var records = globTerminals( abs( '+(alt)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(alt)/*';
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d' ];
  var records = globAll( abs( '+(alt)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +(alt|ctrl)/*'; /* */
  var expectedRelative = [ './alt/a', './altalt/a', './altctrl/a', './altctrlalt/a', './ctrl/a', './ctrlctrl/a' ]
  var records = globTerminals( abs( '+(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +(alt|ctrl)/*';
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d', './altctrl', './altctrl/a', './altctrl/d', './altctrlalt', './altctrlalt/a', './altctrlalt/d', './ctrl', './ctrl/a', './ctrl/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d' ];
  var records = globAll( abs( '+(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *(alt|ctrl)/*'; /* */
  var expectedRelative = [ './alt/a', './altalt/a', './altctrl/a', './altctrlalt/a', './ctrl/a', './ctrlctrl/a' ];
  var records = globTerminals( abs( '*(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *(alt|ctrl)/*';
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './altalt', './altalt/a', './altalt/d', './altctrl', './altctrl/a', './altctrl/d', './altctrlalt', './altctrlalt/a', './altctrlalt/d', './ctrl', './ctrl/a', './ctrl/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d' ];
  var records = globAll( abs( '*(alt|ctrl)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt*(alt|ctrl)?/*'; /* */
  var expectedRelative = [ './alt2/a', './altalt2/a', './altctrl2/a', './altctrlalt2/a' ];
  var records = globTerminals( abs( 'alt*(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt*(alt|ctrl)?/*';
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt2', './altalt2/a', './altalt2/d', './altctrl2', './altctrl2/a', './altctrl2/d', './altctrlalt2', './altctrlalt2/a', './altctrlalt2/d' ];
  var records = globAll( abs( 'alt*(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *(alt|ctrl|2)/*'; /* */
  var expectedRelative = [ './alt/a', './alt2/a', './altalt/a', './altalt2/a', './altctrl/a', './altctrl2/a', './altctrlalt/a', './altctrlalt2/a', './ctrl/a', './ctrl2/a', './ctrlctrl/a', './ctrlctrl2/a' ];
  var records = globTerminals( abs( '*(alt|ctrl|2)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *(alt|ctrl|2)/*';
  var expectedRelative = [ '.', './alt', './alt/a', './alt/d', './alt2', './alt2/a', './alt2/d', './altalt', './altalt/a', './altalt/d',
    './altalt2', './altalt2/a', './altalt2/d', './altctrl', './altctrl/a', './altctrl/d', './altctrl2', './altctrl2/a', './altctrl2/d',
    './altctrlalt', './altctrlalt/a', './altctrlalt/d', './altctrlalt2', './altctrlalt2/a', './altctrlalt2/d', './ctrl', './ctrl/a',
    './ctrl/d', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/a', './ctrlctrl2/d' ];
  var records = globAll( abs( '*(alt|ctrl|2)/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt?(alt|ctrl)?/*'; /* */
  var expectedRelative = [ './alt2/a', './altalt2/a', './altctrl2/a' ];
  var records = globTerminals( abs( 'alt?(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt?(alt|ctrl)?/*';
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt2', './altalt2/a', './altalt2/d', './altctrl2', './altctrl2/a', './altctrl2/d' ];
  var records = globAll( abs( 'alt?(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt!(alt|ctrl)?/*'; /* */
  var expectedRelative = [ './alt2/a' ];
  var records = globTerminals( abs( 'alt!(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt!(alt|ctrl)?/*';
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d' ];
  var records = globAll( abs( 'alt!(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals alt!(ctrl)?/*'; /* */
  var expectedRelative = [ './alt2/a', './altalt/a', './altalt2/a' ];
  var records = globTerminals( abs( 'alt!(ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll alt!(ctrl)?/*';
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './altalt', './altalt/a', './altalt/d', './altalt2', './altalt2/a', './altalt2/d' ];
  var records = globAll( abs( 'alt!(ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals @(alt|ctrl)?/*'; /* */
  var expectedRelative = [ './alt2/a', './ctrl2/a' ];
  var records = globTerminals( abs( '@(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll @(alt|ctrl)?/*';
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './ctrl2', './ctrl2/a', './ctrl2/d' ];
  var records = globAll( abs( '@(alt|ctrl)?/*' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *([c-s])?';
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '*([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *([c-s])?';
  var expectedRelative = [ '.', './srcT', './src', './src1', './src2' ];
  var records = globAll( abs( '*([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([c-s])?';
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '+([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([c-s])?';
  var expectedRelative = [ '.', './srcT', './src', './src1', './src2' ];
  var records = globAll( abs( '+([c-s])?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([lrtc])';
  var expectedRelative = [];
  var records = globTerminals( abs( '.' ), '+([lrtc])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([lrtc])';
  var expectedRelative = [ '.', './ctrl', './ctrlctrl' ];
  var records = globAll( abs( '.' ), '+([lrtc])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([^lt])';
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '.' ), '+([^lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([^lt])';
  var expectedRelative = [ '.', './srcT', './src', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( '.' ), '+([^lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([!lt])';
  var expectedRelative = [ './srcT' ];
  var records = globTerminals( abs( '.' ), '+([!lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([!lt])';
  var expectedRelative = [ '.', './srcT', './src', './src1', './src1b', './src2', './src3.js', './src3.s' ];
  var records = globAll( abs( '.' ), '+([!lt])' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals doubledir/d1/d11/*';
  var expectedRelative = [ './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globTerminals( abs( '.' ), 'doubledir/d1/d11/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll doubledir/d1/d11/*';
  var expectedRelative = [ './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globAll( abs( '.' ), 'doubledir/d1/d11/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**/*';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( '.' ), 'src1/**/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**/*';
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( '.' ), 'src1/**/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals **/*.s';
  var expectedRelative = [ './src3.js/b.s', './src3.s/b.s' ];
  var records = globTerminals( abs( '.' ), '**/*.s' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/*.s';
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/b.s', './src3.js/d', './src3.s', './src3.s/b.s', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**/*.s' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **/*.js';
  var expectedRelative = [ './src3.js/c.js', './src3.s/c.js' ];
  var records = globTerminals( abs( '.' ), '**/*.js' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/*.js';
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/c.js', './src3.js/d', './src3.s', './src3.s/c.js', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**/*.js' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **.s/*';
  var expectedRelative = [ './src3.js/b.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js' ];
  var records = globTerminals( abs( '.' ), '**.s/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **.s/*';
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/b.s', './src3.js/d', './src3.s', './src3.s/a', './src3.s/b.s', './src3.s/c.js', './src3.s/d' ];
  var records = globAll( abs( '.' ), '**.s/*' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1/**';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1/**';
  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1Terminal/**';
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals( './src1Terminal/**' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/**';
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll( abs( 'src1Terminal/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with options map';
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals({ filePath : './src1Terminal/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with options map';
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll({ filePath : './src1Terminal/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with prefixPath';
  var expectedRelative = [ './src1Terminal' ];
  var expectedAbsolute = abs([ './src1Terminal' ]);
  var records = globTerminals
  (
    { filePath : './**', filter : { prefixPath : abs( './src1Terminal' ) } }
  );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1Terminal/** with prefixPath';
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll
  (
    { filePath : './**', filter : { prefixPath : abs( './src1Terminal' ) } }
  );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath and prefixPath, several op';
  var expectedRelative = [ './src1Terminal' ];
  var expectedAbsolute = abs([ './src1Terminal' ]);
  var records = globTerminals
  (
    { filter : { basePath : '.' } },
    { filePath : './**', filter : { prefixPath : abs( './src1Terminal' ) } }
  );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1Terminal/** with basePath and prefixPath, several op';
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll
  (
    { filter : { basePath : '.' } },
    { filePath : './**', filter : { prefixPath : abs( './src1Terminal' ) } }
  );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath and prefixPath';
  var expectedRelative = [ '.' ];
  var expectedAbsolute = abs([ './src1Terminal' ]);
  var records = globTerminals({ filePath : './**', filter : { basePath : '.', prefixPath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1Terminal/** with basePath and prefixPath';
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : './**', filter : { basePath : '.', prefixPath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal with basePath and relative filePath';
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : '.', filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal with basePath and relative filePath';
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : '.', filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal with basePath and absolute filePath';
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal with basePath and absolute filePath';
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath';
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath';
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : abs( './src1Terminal' ) } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminalsWithPrefix src1Terminal/** with basePath:empty and prefixPath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globTerminalsWithPrefix({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '', prefixPath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAllWithPrefix src1Terminal/** with basePath:empty and prefixPath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globAllWithPrefix({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '', prefixPath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1Terminal/** with basePath:empty and prefixPath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '', prefixPath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath:empty and prefixPath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '', prefixPath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals src1Terminal/** with basePath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath:empty';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ '.' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath:null and prefixPath:null';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null, prefixPath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath:null and prefixPath:null';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null, prefixPath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals src1Terminal/** with basePath:null';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ './src1Terminal' ];
  var records = globTerminals({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll src1Terminal/** with basePath:null';
  var expectedAbsolute = path.s.join( routinePath, [ './src1Terminal' ] );
  var expectedRelative = [ './src1Terminal' ];
  var records = globAll({ filePath : abs( 'src1Terminal/**' ), filter : { basePath : null } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';
  var expectedAbsolute = path.s.join( routinePath, [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ] );
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filePath : [ abs( './doubledir/d1/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/** ] with prefixPath:null, basePath:/doubledir/d1';
  var expectedAbsolute = path.s.join( routinePath, [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ] );
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filePath : [ abs( './doubledir/d1/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';
  var expectedAbsolute = path.s.join( routinePath, [ './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ] );
  var expectedRelative = [ '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : [ abs( './doubledir/d2/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d2/** ] with prefixPath:null, basePath:/doubledir/d1';
  var expectedRelative = [ './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var expectedRelative = [ '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : [ abs( './doubledir/d2/**' ) ], filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [c-s][c-s][c-s][0-9]/**';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [c-s][c-s][c-s][0-9]/**';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '[c-s][c-s][c-s][0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals *([c-s])[0-9]/**';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src2/a', './src2/b', './src2/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '*([c-s])[0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll *([c-s])[0-9]/**';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2', './src2/a', './src2/b', './src2/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '*([c-s])[0-9]/**' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals +([crs1])/**/+([abc])';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '+([crs1])/**/+([abc])' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll +([crs1])/**/+([abc])';
  var expectedRelative = [ '.', './src', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '+([crs1])/**/+([abc])' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals **/d11/*';
  var expectedRelative = [ './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var records = globTerminals({ filter : { prefixPath : abs( '.' ) }, filePath : '**/d11/*' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **/d11/*';
  var expectedRelative = [ '.', './alt', './alt/d', './alt2', './alt2/d', './altalt', './altalt/d', './altalt2', './altalt2/d', './altctrl', './altctrl/d', './altctrl2', './altctrl2/d', './altctrlalt', './altctrlalt/d', './altctrlalt2', './altctrlalt2/d', './ctrl', './ctrl/d', './ctrl2', './ctrl2/d', './ctrlctrl', './ctrlctrl/d', './ctrlctrl2', './ctrlctrl2/d', './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './src', './src1', './src1/d', './src1b', './src2', './src2/d', './src3.js', './src3.js/d', './src3.s', './src3.s/d' ];
  var records = globAll({ filter : { prefixPath : abs( '.' ) }, filePath : '**/d11/*' });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals filePath : **, prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filter : { filePath : '**', prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : **, prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11';
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filter : { filePath : '**', prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, no filePath';
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '../a', './b', './c' ];
  var records = globTerminals({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, no filePath';
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c' ];
  var expectedRelative = [ '..', '../a', '.', './b', './c' ];
  var records = globAll({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'globTerminals prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';
  var expectedAbsolute = abs([ './doubledir/d1/d11/b' ]);
  var expectedRelative = [ './b' ];
  var records = globTerminals({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) }, filePath : 'b' });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll prefixPath : /doubledir/d1/**, basePath:/doubledir/d1/d11, filePath:b';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b' ]);
  var expectedRelative = [ '..', '.', './b' ];
  var records = globAll({ filter : { prefixPath : abs( './doubledir/d1/**' ), basePath : abs( './doubledir/d1/d11' ) }, filePath : 'b' });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.open( 'several paths' );

  /* - */

  test.case = 'globTerminals [ /src1/d/**, /src2/d/** ]';
  var expectedRelative = [ './src1/d/a', './src1/d/b', './src1/d/c', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globTerminals({ filePath : [ './src1/d/**', './src2/d/**' ] });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /src1/d/**, /src2/d/** ]';
  var expectedRelative = [ './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var records = globAll({ filePath : [ './src1/d/**', './src2/d/**' ] });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ], no options map';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ], no options map';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll([ './doubledir/d1/**', './doubledir/d2/**' ]);
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ]';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ]';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals( { filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : routinePath } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : routinePath } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]) }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:empty';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]) }, { filter : { basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globTerminals( { filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:.';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : null } }, { filter : { basePath : '.' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:+/doubledir';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : './doubledir', prefixPath : routinePath } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:+/doubledir';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ filePath : [ './doubledir/d1/**', './doubledir/d2/**' ], filter : { basePath : './doubledir', prefixPath : routinePath } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1/a', './d1/d11/b', './d1/d11/c', './d2/b', './d2/d22/c', './d2/d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with basePath:/doubledir';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './d1', './d1/a', './d1/d11', './d1/d11/b', './d1/d11/c', './d2', './d2/b', './d2/d22', './d2/d22/c', './d2/d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:empty, basePath : empty';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/b', './d11/c', './b', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : '', basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ] with prefixPath:empty, basePath : empty';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/b', './d11/c', '.', './b', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { prefixPath : '', basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals [ /ctrl/**, /ctrlctrl/** ] with prefixPath:empty, basePath : empty';
  var expectedAbsolute = abs([ './ctrl/a', './ctrl/d/a', './ctrlctrl/a', './ctrlctrl/d/a' ]);
  var expectedRelative = [ './a', './d/a', './a', './d/a' ];
  var records = globTerminals({ filePath : abs([ './ctrl/**', './ctrlctrl/**' ]), filter : { prefixPath : '', basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /ctrl/**, /ctrlctrl/** ] with prefixPath:empty, basePath : empty';
  var expectedAbsolute = abs([ './ctrl', './ctrl/a', './ctrl/d', './ctrl/d/a', './ctrlctrl', './ctrlctrl/a', './ctrlctrl/d', './ctrlctrl/d/a' ]);
  var expectedRelative = [ '.', './a', './d', './d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs([ './ctrl/**', './ctrlctrl/**' ]), filter : { prefixPath : '', basePath : '' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globTerminals [ /doubledir/d1/**, /doubledir/d2/** ], basePath:/doubledir/d1';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2/b', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', './c', '../../d2/b', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminalsWithPrefix({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll [ /doubledir/d1/**, /doubledir/d2/** ], basePath:/doubledir/d1';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', './c', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAllWithPrefix({ filePath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  var expectedAbsolute = abs([ './doubledir/d1/d11/b', './doubledir/d2/b' ]);
  var expectedRelative = [ './b', '../../d2/b' ];
  // var records = globTerminals({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : './doubledir/d1/d11' } });
  var records = globTerminals({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll **b** : 0, prefixPath : [ /doubledir/d1, /doubledir/d2 ], basePath:/doubledir/d1';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22' ]);
  var expectedRelative = [ '..', '.', './b', '../../d2', '../../d2/b', '../../d2/d22' ];
  // var records = globAll({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : './doubledir/d1/d11' } });
  var records = globAll({ filePath : '**b**', filter : { prefixPath : abs([ './doubledir/d1', './doubledir/d2' ]), basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.close( 'several paths' );

  /* - */

  test.open( 'glob map' );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, **b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  // var expectedAbsolute = abs([ 'doubledir/d1/a', 'doubledir/d1/d11/c', 'doubledir/d2/d22/c', 'doubledir/d2/d22/d' ]);
  // var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  // var expectedAbsolute = abs([ 'doubledir/d1', 'doubledir/d1/a', 'doubledir/d1/d11', 'doubledir/d1/d11/c', 'doubledir/d2', 'doubledir/d2/d22', 'doubledir/d2/d22/c', 'doubledir/d2/d22/d' ]);
  // var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var expectedAbsolute = abs([]);
  var expectedRelative = [];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**b**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d2/b', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', '../../d2/b', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : null, /doubledir/d2/** : null, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : null, [ abs( './doubledir/d2/**' ) ] : null, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ 'doubledir/d1/a', 'doubledir/d1/d11/b', 'doubledir/d2/b', 'doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', '../../d2/b', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, ../../**c** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  // var expectedAbsolute = abs([ 'doubledir/d1', 'doubledir/d1/d11', 'doubledir/d2', 'doubledir/d2/d22' ]);
  // var expectedRelative = [ '..', '.', '../../d2', '../../d2/d22' ];
  var expectedAbsolute = abs([ 'doubledir/d1', 'doubledir/d1/a', 'doubledir/d1/d11', 'doubledir/d1/d11/b', 'doubledir/d2', 'doubledir/d2/b', 'doubledir/d2/d22', 'doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, '../../**c**' : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : 1, /doubledir/d2/** : 1, /doubledir/**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : 1, /doubledir/d2/** : 1, /doubledir/**b** : 0 } with prefixPath:null, basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { [ abs( './doubledir/d1/**' ) ] : 1, [ abs( './doubledir/d2/**' ) ] : 1, [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : null, basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : empty, /doubledir/d2/** : null, **c** : 0 } with basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/b', './doubledir/d2/b', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', '../../d2/b', '../../d2/d22/d' ];
  var records = globTerminalsWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : null, '**c**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : empty, /doubledir/d2/** : null, **c** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/d' ];
  var records = globAllWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : null, '**c**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : empty, /doubledir/d2/** : empty, doubledir/*/**b** : 0 } with basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminalsWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : '', 'doubledir/*/**b**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : empty, /doubledir/d2/** : empty, doubledir/*/**b** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAllWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : '', 'doubledir/*/**b**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals { /doubledir/d1/** : empty, /doubledir/d2/** : empty, **b** : 0 } with basePath:/doubledir/d1/d11';
  // var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedAbsolute = abs([ 'doubledir/d1/a', 'doubledir/d1/d11/b', 'doubledir/d2/b', 'doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './b', '../../d2/b', '../../d2/d22/d' ];
  var records = globTerminalsWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : '', '**c**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll { /doubledir/d1/** : empty, /doubledir/d2/** : empty, **b** : 0 } with prefixPath : [ ../../d1, ../../d2 ], basePath:/doubledir/d1/d11';
  // var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  // var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var expectedAbsolute = abs([ 'doubledir/d1', 'doubledir/d1/a', 'doubledir/d1/d11', 'doubledir/d1/d11/b', 'doubledir/d2', 'doubledir/d2/b', 'doubledir/d2/d22', 'doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './b', '../../d2', '../../d2/b', '../../d2/d22', '../../d2/d22/d' ];
  var records = globAllWithPrefix({ filePath : { [ abs( './doubledir/d1/**' ) ] : '', [ abs( './doubledir/d2/**' ) ] : '', '**c**' : 0 }, filter : { basePath : './doubledir/d1/d11' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ 'doubledir/d1/d11/b', 'doubledir/d2/b' ]);
  var expectedRelative = [ '../d1/d11/b', '../d2/b' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/**b**' ) ] : '' }, filter : { basePath : abs( './doubledir/doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ 'doubledir', 'doubledir/d1', 'doubledir/d1/d11', 'doubledir/d1/d11/b', 'doubledir/d2', 'doubledir/d2/b', 'doubledir/d2/d22' ]);
  var expectedRelative = [ '..', '../d1', '../d1/d11', '../d1/d11/b', '../d2', '../d2/b', '../d2/d22' ];
  var records = globAll({ filePath : { [ abs( './doubledir/**b**' ) ] : '' }, filter : { basePath : abs( './doubledir/doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals filePath : { **b** : empty }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/d11/b', './doubledir/d2/b' ]);
  var expectedRelative = [ './d1/d11/b', './d2/b' ];
  var records = globTerminals({ filePath : { [ abs( './doubledir/**b**' ) ] : '' }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { **b** : empty }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir', './doubledir/d1', './doubledir/d1/d11', './doubledir/d1/d11/b', './doubledir/d2', './doubledir/d2/b', './doubledir/d2/d22' ]);
  var expectedRelative = [ '.', './d1', './d1/d11', './d1/d11/b', './d2', './d2/b', './d2/d22' ];
  var records = globAll({ filePath : { [ abs( './doubledir/**b**' ) ] : '' }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : abs( './doubledir' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ './a', './d11/c', './d22/c', './d22/d' ];
  var records = globTerminals({ filePath : { '.' : '', [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : '.' } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '.', './a', './d11', './d11/c', '.', './d22', './d22/c', './d22/d' ];
  var records = globAll({ filePath : { '.' : '', [ abs( './doubledir/**b**' ) ] : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : '.' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'globTerminals filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1/a', './doubledir/d1/d11/c', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '../a', './c', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globTerminals({ filePath : { '.' : '', '**b**' : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : abs( './doubledir/d1/d11' ) } });
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { . : empty, **b** : 0 }, prefixPath : [ /doubledir/d1/**, /doubledir/d2/** ], basePath : /doubledir/d1/d11';
  var expectedAbsolute = abs([ './doubledir/d1', './doubledir/d1/a', './doubledir/d1/d11', './doubledir/d1/d11/c', './doubledir/d2', './doubledir/d2/d22', './doubledir/d2/d22/c', './doubledir/d2/d22/d' ]);
  var expectedRelative = [ '..', '../a', '.', './c', '../../d2', '../../d2/d22', '../../d2/d22/c', '../../d2/d22/d' ];
  var records = globAll({ filePath : { '.' : '', '**b**' : 0 }, filter : { prefixPath : abs([ './doubledir/d1/**', './doubledir/d2/**' ]), basePath : abs( './doubledir/d1/d11' ) } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : null, /alt2** : null }';
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './ctrl2/**' : null, './alt2**' : null }), filter : { prefixPath : '', basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : null, /alt2** : null }';
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './alt2**' : null, './ctrl2/**' : null }), filter : { prefixPath : '', basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : 1, /alt2** : 1 }';
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './ctrl2/**' : 1, './alt2**' : 1 }), filter : { prefixPath : '', basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.case = 'globAll filePath : { /ctrl2/** : 1, /alt2** : 1 }';
  var expectedAbsolute = abs([ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', './ctrl2', './ctrl2/a', './ctrl2/d', './ctrl2/d/a' ]);
  var expectedRelative = [ '.', './alt2', './alt2/a', './alt2/d', './alt2/d/a', '.', './a', './d', './d/a' ];
  var records = globAll({ filePath : abs({ './alt2**' : 1, './ctrl2/**' : 1 }), filter : { prefixPath : '', basePath : '' } } );
  var gotAbsolute = _.select( records, '*/absolute' );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotAbsolute, expectedAbsolute );
  test.identical( gotRelative, expectedRelative );

  test.close( 'glob map' );

  /* - */

}

filesFindGlob.timeOut = 300000;

//

function filesFindOn( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = context.makeStandardExtract();
  src.filesReflectTo( provider, routinePath );

  var onUp = function onUp( record )
  {
    if( record.isTransient )
    onUpRelativeTransients.push( record.relative );
    if( record.isActual )
    onUpRelativeActuals.push( record.relative );
    return record;
  }

  var onDown = function onDown( record )
  {
    if( record.isTransient )
    onDownRelativeTransients.push( record.relative );
    if( record.isActual )
    onDownRelativeActuals.push( record.relative );
    // return record;
  }

  function selectTransients( records )
  {
    return _.filter( records, ( record ) => record.isTransient ? record.relative : undefined );
  }

  function selectActuals( records )
  {
    return _.filter( records, ( record ) => record.isActual ? record.relative : undefined );
  }

  var onUpRelativeTransients = [];
  var onUpRelativeActuals = [];
  var onDownRelativeTransients = [];
  var onDownRelativeActuals = [];

  function clean()
  {
    onUpRelativeTransients = [];
    onUpRelativeActuals = [];
    onDownRelativeTransients = [];
    onDownRelativeActuals = [];
  }

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var globTerminals = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globAll = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globTerminalsWithPrefix = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  var globAllWithPrefix = provider.filesGlober
  ({
    onUp : onUp,
    onDown : onDown,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  /* - */

  test.open( 'extended' );

  test.case = 'globTerminals src1/**'; /* */

  clean();

  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var records = globTerminals( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll src1/**';

  clean();

  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnUpAbsoluteTransients = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteTransients = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1/d', './src1' ];
  var expectedOnUpAbsoluteActuals = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c', './src1/d', './src1' ];
  var records = globAll( abs( 'src1/**' ) );
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globTerminals src1/** relative';

  clean();

  var expectedRelative = [ './src1/a', './src1/b', './src1/c' ];
  var expectedOnUpAbsoluteTransients = [];
  var expectedOnDownAbsoluteTransients = [];
  var expectedOnUpAbsoluteActuals = [ './src1/a', './src1/b', './src1/c' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c' ];
  var records = globTerminals({ filePath : '*', filter : { prefixPath : abs( 'src1' ) } });
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.case = 'globAll src1/** relative';

  clean();

  var expectedRelative = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var expectedOnUpAbsoluteTransients = [ './src1', './src1/d' ];
  var expectedOnDownAbsoluteTransients = [ './src1/d', './src1' ];
  var expectedOnUpAbsoluteActuals = [ './src1', './src1/a', './src1/b', './src1/c', './src1/d' ];
  var expectedOnDownAbsoluteActuals = [ './src1/a', './src1/b', './src1/c', './src1/d', './src1' ];
  var records = globAll({ filePath : '*', filter : { prefixPath : abs( 'src1' ) } });
  var gotRelative = _.select( records, '*/relative' );

  test.identical( gotRelative, expectedRelative );
  test.identical( onUpRelativeTransients, expectedOnUpAbsoluteTransients );
  test.identical( onDownRelativeTransients, expectedOnDownAbsoluteTransients );
  test.identical( onUpRelativeActuals, expectedOnUpAbsoluteActuals );
  test.identical( onDownRelativeActuals, expectedOnDownAbsoluteActuals );

  test.close( 'extended' );

}

//

function filesFindBaseFromGlob( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = context.makeStandardExtract();
  src.filesReflectTo( provider, routinePath );

  function selectTransients( records )
  {
    return _.filter( records, ( record ) => record.isTransient ? record.relative : undefined );
  }

  function selectActuals( records )
  {
    return _.filter( records, ( record ) => record.isActual ? record.relative : undefined );
  }

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var globTerminals = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globAll = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { basePath : routinePath },
  });

  var globTerminalsWithPrefix = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 0,
    includingTransient : 0,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  var globAllWithPrefix = provider.filesGlober
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    recursive : 2,
    filter : { prefixPath : routinePath },
  });

  /* - */

  test.open( 'base marker ()' );

  /* - */

  test.case = 'globTerminals src1()';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminals({ filePath : './src1()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1()';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAll({ filePath : './src1()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals src1/a()';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminals({ filePath : './src1/a()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1/a()';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ 'src1', 'src1/a' ]);
  var records = globAll({ filePath : './src1/a()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals src1/()a';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminals({ filePath : './src1/()a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1/()a';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ './src1', './src1/a' ]);
  var records = globAll({ filePath : './src1/()a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals ()src1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminals({ filePath : './()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll ()src1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAll({ filePath : './()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals sr()c1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminals({ filePath : './sr()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll sr()c1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAll({ filePath : './sr()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* - */

  test.close( 'base marker ()' );
  test.open( 'base marker *()' );

  /* - */

  test.case = 'globTerminals src1/d';
  var expectedRelative = [ './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminals({ filePath : './src1/d' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1/d';
  var expectedRelative = [ './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAll({ filePath : './src1/d' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals : src1/d, base : src1';
  var expectedRelative = [ './d/a', './d/b', './d/c' ];
  var expectedAbsolute = abs([ './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminals({ filter : { filePath : abs( './src1/d' ), basePath : abs( './src1' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll : src1/d, base : src1';
  var expectedRelative = [ './d', './d/a', './d/b', './d/c' ];
  var expectedAbsolute = abs([ './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAll({ filter : { filePath : abs( './src1/d' ), basePath : abs( './src1' ) } });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals src1/d*()';
  var expectedRelative = [ './d/a', './d/b', './d/c' ];
  var expectedAbsolute = abs([ './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminals({ filePath : './src1/d*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1/d*()';
  var expectedRelative = [ '.', './d', './d/a', './d/b', './d/c' ];
  var expectedAbsolute = abs([ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAll({ filePath : './src1/d*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals *()./src1';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminals({ filePath : '*()./src1' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll *()./src1';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAll({ filePath : '*()./src1' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix src1/a*()';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix src1/a*()';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminals src1/a*()';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminals({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAll src1/a*()';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ './src1', './src1/a' ]);
  var records = globAll({ filePath : './src1/a*()' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix src1/*()a';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './src1/*()a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix src1/*()a';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './src1/*()a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix *()src1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './*()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix *()src1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './*()src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix sr*()c1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './sr*()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix sr*()c1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './sr*()c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* - */

  test.close( 'base marker *()' );
  test.open( 'base marker \\0' );

  /* - */

  test.case = 'globTerminalsWithPrefix src1\\0';
  var expectedRelative = [ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ './src1/a', './src1/b', './src1/c', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globTerminalsWithPrefix({ filePath : './src1\0' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix src1\\0';
  var expectedRelative = [ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a', './src1/b', './src1/c', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c' ]);
  var records = globAllWithPrefix({ filePath : './src1\0' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix src1/a\\0';
  var expectedRelative = [ './a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './src1/a\0' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix src1/a\\0';
  var expectedRelative = [ '.', './a' ];
  var expectedAbsolute = abs([ './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './src1/a\0' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix \\0src1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './\0src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix \\0src1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './\0src1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* */

  test.case = 'globTerminalsWithPrefix sr\\0c1/a';
  var expectedRelative = [ './src1/a' ];
  var expectedAbsolute = abs([ './src1/a' ]);
  var records = globTerminalsWithPrefix({ filePath : './sr\0c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  test.case = 'globAllWithPrefix sr\\0c1/a';
  var expectedRelative = [ '.', './src1', './src1/a' ];
  var expectedAbsolute = abs([ '.', './src1', './src1/a' ]);
  var records = globAllWithPrefix({ filePath : './sr\0c1/a' });
  var gotRelative = _.select( records, '*/relative' );
  var gotAbsolute = _.select( records, '*/absolute' );
  test.identical( gotRelative, expectedRelative );
  test.identical( gotAbsolute, expectedAbsolute );

  /* - */

  test.close( 'base marker \\0' );

}

filesFindBaseFromGlob.timeOut = 150000;

//

function filesGlob( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var filesTree =
  {
    'a' :
    {
      'a.js' : '',
      'a.s' : '',
      'a.ss' : '',
      'a.txt' : '',
      'c' :
      {
        'c.js' : '',
        'c.s' : '',
        'c.ss' : '',
        'c.txt' : '',
      }
    },
    'b' :
    {
      'a' :
      {
        'x' :
        {
          'a' :
          {
            'a.js' : '',
            'a.s' : '',
            'a.ss' : '',
            'a.txt' : '',
          }
        }
      }
    },

    'a.js' : '',
    'a.s' : '',
    'a.ss' : '',
    'a.txt' : '',
  }

  var extract1 = new _.FileProvider.Extract({ filesTree : filesTree });
  extract1.filesReflectTo( provider, routinePath );

  var commonOptions  =
  {
    outputFormat : 'relative',
  }

  function completeOptions( glob )
  {
    var options = _.mapExtend( null, commonOptions );
    options.filePath = path.join( routinePath, glob );
    return options
  }

  /* - */

  test.case = 'simple glob';

  var glob = '*';
  var got = provider.filesGlob( completeOptions( glob ) );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt'
  ];
  test.identical( got, expected );

  var glob = '**'
  var got = provider.filesGlob( completeOptions( glob ) );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt',
    './a/a.js',
    './a/a.s',
    './a/a.ss',
    './a/a.txt',
    './a/c/c.js',
    './a/c/c.s',
    './a/c/c.ss',
    './a/c/c.txt',
    './b/a/x/a/a.js',
    './b/a/x/a/a.s',
    './b/a/x/a/a.ss',
    './b/a/x/a/a.txt'
  ]
  test.identical( got, expected );

  var  glob = 'a/*.js';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/a.*';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.js',
    './a.s',
    './a.ss',
    './a.txt'
  ]
  test.identical( got, expected );

  var  glob = 'a/a.j?';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.js',
  ]
  test.identical( got, expected );

  var  glob = 'a/[!cb].s';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a.s',
  ]
  test.identical( got, expected );

  /**/

  test.case = 'complex glob';

  var  glob = '**/a/a.?';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/a.s', './b/a/x/a/a.s'
  ]
  test.identical( got, expected );

  var  glob = '**/x/**/a.??';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './b/a/x/a/a.js',
    './b/a/x/a/a.ss',
  ]
  test.identical( got, expected );

  var  glob = '**/[!ab]/*.?s';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/c/c.js',
    './a/c/c.ss',
  ]
  test.identical( got, expected );

  var  glob = 'b/[a-c]/**/a/*';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/x/a/a.js',
    './a/x/a/a.s',
    './a/x/a/a.ss',
    './a/x/a/a.txt'
  ]
  test.identical( got, expected );

  var glob = '[ab]/**/[!xc]/*';
  var options = completeOptions( glob );
  var got = provider.filesGlob( options );
  // var expected = [ './a/a.js', './a/a.s', './a/a.ss', './a/a.txt', './a/c/c.js', './a/c/c.s', './a/c/c.ss', './a/c/c.txt', './b/a/x/a/a.js', './b/a/x/a/a.s', './b/a/x/a/a.ss', './b/a/x/a/a.txt' ]
  var expected = [ './b/a/x/a/a.js', './b/a/x/a/a.s', './b/a/x/a/a.ss', './b/a/x/a/a.txt' ];
  test.identical( got, expected );

/*
  var filesTree =
  {
    'a' :
    {
      'a.js' : '',
      'a.s' : '',
      'a.ss' : '',
      'a.txt' : '',
      'c' :
      {
        'c.js' : '',
        'c.s' : '',
        'c.ss' : '',
        'c.txt' : '',
      }
    },
    'b' :
    {
      'a' :
      {
        'x' :
        {
          'a' :
          {
            'a.js' : '',
            'a.s' : '',
            'a.ss' : '',
            'a.txt' : '',
          }
        }
      }
    },

    'a.js' : '',
    'a.s' : '',
    'a.ss' : '',
    'a.txt' : '',
  }

*/

  /**/

  var glob = '**/*.s';
  var options =
  {
    filePath : path.join( routinePath, 'a/c', glob ),
    outputFormat : 'relative',
    filter: { basePath : routinePath }
  }
  var got = provider.filesGlob( options );
  var expected =
  [
    './a/c/c.s',
  ]
  test.identical( got, expected );

  /**/

  /* {} are not supported */

  // var  glob = 'a/{x.*, a.*}';
  // var options = completeOptions( glob );
  // var got = provider.filesGlob( options );
  // var expected =
  // [
  //   './a.js',
  //   './a.s',
  //   './a.ss',
  //   './a.txt'
  // ]
  // test.identical( got, expected );
  //
  // var  glob = '**/c/{x.*, c.*}';
  // var options = completeOptions( glob );
  // var got = provider.filesGlob( options );
  // var expected =
  // [
  //   './a/c/c.js',
  //   './a/c/c.s',
  //   './a/c/c.ss',
  //   './a/c/c.txt',
  // ]
  // test.identical( got, expected );
  //
  // var  glob = 'b/*/{x, c}/a/*';
  // var options = completeOptions( glob );
  // var got = provider.filesGlob( options );
  // var expected =
  // [
  //   './a/x/a/a.js',
  //   './a/x/a/a.s',
  //   './a/x/a/a.ss',
  //   './a/x/a/a.txt'
  // ]
  // test.identical( got, expected );

}

//

function filesFindDistinct( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  test.case = 'setup';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 :
      {
        t1 : '/dir1/t1',
        t2 : '/dir1/t2',
        dir11 : { t3 : '/dir1/dir11/t3' }
      },
      dir2 :
      {
        t21 : '/dir2/t21'
      }
    },
  });

  extract1.filesReflectTo( provider, routinePath );

  /* */

  test.case = 'exist';

  var filter =
  {
    filePath : abs( 'dir1' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1' ]);
  test.identical( got, expected );

  /* */

  test.case = 'exist, includingDirs : 0';

  var filter =
  {
    filePath : abs( 'dir1' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    includingDirs : 0,
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([]);
  test.identical( got, expected );

  /* */

  test.case = 'exist, glob';

  var filter =
  {
    filePath : abs( 'dir1*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1/t1', 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );

  /* */

  test.case = 'exist, glob, includingDirs : 0';

  var filter =
  {
    filePath : abs( 'dir1*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    includingDirs : 0,
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1/t1', 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );

  /* */

  test.case = 'exist, glob, includingDirs : 1';

  var filter =
  {
    filePath : abs( 'dir1*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    includingDirs : 1,
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1', 'dir1/t1', 'dir1/t2', 'dir1/dir11', 'dir1/dir11/t3' ]);
  test.identical( got, expected );

  /* */

  test.case = 'does not exist';

  var filter =
  {
    filePath : abs( 'dirX' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dirX' ]);
  test.identical( got, expected );

  /* */

  test.case = 'does not exist 2';

  var filter =
  {
    filePath : abs( 'dirX/dirY' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dirX/dirY' ]);
  test.identical( got, expected );

  /* */

  test.case = 'does not exist, mandatory : 1';

  var filter =
  {
    filePath : abs( 'dirX' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mandatory : 1,
    mode : 'distinct',
    filter,
  }

  test.shouldThrowErrorSync( () =>
  {
    var got = provider.filesFind( _.mapExtend( null, o1 ) );
    var expected = abs([]);
    test.identical( got, expected );
  });

  /* */

  test.case = 'does not exist, glob';

  var filter =
  {
    filePath : abs( 'dirX*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  test.shouldThrowErrorSync( () =>
  {
    var got = provider.filesFind( _.mapExtend( null, o1 ) );
    var expected = abs([]);
    test.identical( got, expected );
  });

  /* */

  test.case = 'does not exist, glob, mandatory : 0';

  var filter =
  {
    filePath : abs( 'dirX*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mandatory : 0,
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([]);
  test.identical( got, expected );

  /* */

  test.case = 'does not exist, glob, mandatory : 0, includingDirs : 1, includingStem : 1';

  var filter =
  {
    filePath : abs( 'dirX*/*/*' ),
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mandatory : 0,
    includingDirs : 1,
    includingStem : 1,
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([]);
  test.identical( got, expected );

  /* */

  test.case = 'exclude dir1/t1*';

  var filter =
  {
    filePath :
    {
      [ abs( 'dir1/**' ) ] : '',
      [ abs( 'dir1/t1*' ) ] : 0,
    },
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );

  /* */

  test.case = 'exclude dir1/t1';

  var filter =
  {
    filePath :
    {
      [ abs( 'dir1/**' ) ] : '',
      [ abs( 'dir1/t1' ) ] : 0,
    },
  }

  var o1 =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( _.mapExtend( null, o1 ) );
  var expected = abs([ 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );

  /* - */

}

//

/*
test glob simplifying feature
optimization which does not add glob masks because it changes nothing
*/

function filesFindSimplifyGlob( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  test.case = 'setup';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      dir1 :
      {
        t1 : '/dir1/t1',
        t2 : '/dir1/t2',
        dir11 : { t3 : '/dir1/dir11/t3' }
      },
      dir2 :
      {
        t21 : '/dir2/t21'
      }
    },
  });

  extract1.filesReflectTo( provider, routinePath );

  /* */

  test.case = 'dir1/**, mode:legacy';

  var filter =
  {
    filePath : abs( 'dir1/**' ),
  }

  var o =
  {
    outputFormat : 'absolute',
    mode : 'legacy',
    filter,
  }

  var got = provider.filesFind( o );
  var expected = abs([ 'dir1/t1', 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );
  test.identical( o.mandatory, false )
  test.identical( o.recursive, 2 )
  test.identical( o.includingTerminals, true );
  test.identical( o.includingDirs, false );
  test.identical( o.includingStem, true );
  test.identical( o.includingActual, 1 );
  test.identical( o.includingTransient, 0 );

  test.identical( o.filter.formedFilterMap, null );
  test.identical( o.filter.formed, 5 );
  test.identical( o.filter.formedFilePath, { [ abs( 'dir1' ) ] : '' } );
  test.identical( o.filter.formedBasePath, { [ abs( 'dir1' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.filePath, { [ abs( 'dir1\/**' ) ] : '' } );
  test.identical( o.filter.basePath, { [ abs( 'dir1\/**' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.prefixPath, null );
  test.identical( o.filter.postfixPath, null );

  /* */

  test.case = 'dir1/**, mode:distinct';

  var filter =
  {
    filePath : abs( 'dir1/**' ),
  }

  var o =
  {
    outputFormat : 'absolute',
    mode : 'distinct',
    filter,
  }

  var got = provider.filesFind( o );
  var expected = abs([ 'dir1/t1', 'dir1/t2', 'dir1/dir11/t3' ]);
  test.identical( got, expected );
  test.identical( o.mandatory, true )
  test.identical( o.recursive, 2 )
  test.identical( o.includingTerminals, true );
  test.identical( o.includingDirs, false );
  test.identical( o.includingStem, true );
  test.identical( o.includingActual, 1 );
  test.identical( o.includingTransient, 0 );

  test.identical( o.filter.formedFilterMap, null );
  test.identical( o.filter.formed, 5 );
  test.identical( o.filter.formedFilePath, { [ abs( 'dir1' ) ] : '' } );
  test.identical( o.filter.formedBasePath, { [ abs( 'dir1' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.filePath, { [ abs( 'dir1\/**' ) ] : '' } );
  test.identical( o.filter.basePath, { [ abs( 'dir1\/**' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.prefixPath, null );
  test.identical( o.filter.postfixPath, null );

  /* */

  test.case = 'dir1/*, distinct:0';

  var filter =
  {
    filePath : abs( 'dir1/*' ),
  }

  var o =
  {
    outputFormat : 'absolute',
    mode : 'legacy',
    filter,
  }

  var got = provider.filesFind( o );
  var expected = abs([ 'dir1/t1', 'dir1/t2' ]);
  test.identical( got, expected );
  test.identical( o.mandatory, false )
  test.identical( o.recursive, 2 )
  test.identical( o.includingTerminals, true );
  test.identical( o.includingDirs, false );
  test.identical( o.includingStem, true );
  test.identical( o.includingActual, 1 );
  test.identical( o.includingTransient, 0 );

  test.setsAreIdentical( _.mapKeys( o.filter.formedFilterMap ), [ abs( 'dir1' ) ] );
  test.identical( o.filter.formedFilterMap[ abs( 'dir1' ) ].maskAll.includeAll.length, 0 );
  test.identical( o.filter.formedFilterMap[ abs( 'dir1' ) ].maskAll.includeAny.length, 1 );
  test.identical( o.filter.formed, 5 );
  test.identical( o.filter.formedFilePath, { [ abs( 'dir1' ) ] : '' } );
  test.identical( o.filter.formedBasePath, { [ abs( 'dir1' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.filePath, { [ abs( 'dir1\/*' ) ] : '' } );
  test.identical( o.filter.basePath, { [ abs( 'dir1\/*' ) ] : abs( 'dir1' ) } );
  test.identical( o.filter.prefixPath, null );
  test.identical( o.filter.postfixPath, null );

}

//

function filesFindMandatoryString( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      module1 :
      {
        amid :
        {
          'terminal' : 'module1/amid/terminal',
        },
      },
      module2 :
      {
      },
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree });

  extract.filesReflectTo( provider, routinePath );

  var o1 =
  {
    filePath : routinePath + '/module2/amid',
    mandatory : 0,
    recursive : 0,
    outputFormat : 'absolute',
  }

  /**/

  test.case = 'default';
  var o2 = _.mapExtend( null, o1 );
  var found = provider.filesFind( o2 );
  var expected = abs([]);
  test.identical( found, expected );

  /**/

  test.case = 'includingDefunct : 0, mandatory : 0, recursive : 0';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 0;
  o2.mandatory = 0;
  o2.recursive = 0;
  var found = provider.filesFind( o2 );
  var expected = abs([]);
  test.identical( found, expected );

  /**/

  test.case = 'includingDefunct : 0, mandatory : 0, recursive : 1';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 0;
  o2.mandatory = 0;
  o2.recursive = 1;
  var found = provider.filesFind( o2 );
  var expected = abs([]);
  test.identical( found, expected );

  /**/

  test.case = 'includingDefunct : 0, mandatory : 1, recursive : 0';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 0;
  o2.mandatory = 1;
  o2.recursive = 0;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs([]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'includingDefunct : 0, mandatory : 1, recursive : 1';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 0;
  o2.mandatory = 1;
  o2.recursive = 1;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs([]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'includingDefunct : 1, mandatory : 0, recursive : 0';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 1;
  o2.mandatory = 0;
  o2.recursive = 0;
  var found = provider.filesFind( o2 );
  var expected = abs([ 'module2/amid' ]);
  test.identical( found, expected );

  /**/

  test.case = 'includingDefunct : 1, mandatory : 0, recursive : 1';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 1;
  o2.mandatory = 0;
  o2.recursive = 1;
  var found = provider.filesFind( o2 );
  var expected = abs([ 'module2/amid' ]);
  test.identical( found, expected );

  /**/

  test.case = 'includingDefunct : 1, mandatory : 1, recursive : 0';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 1;
  o2.mandatory = 1;
  o2.recursive = 0;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs([]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'includingDefunct : 1, mandatory : 1, recursive : 1';
  var o2 = _.mapExtend( null, o1 );
  o2.includingDefunct = 1;
  o2.mandatory = 1;
  o2.recursive = 1;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs([]);
    test.identical( found, expected );
  });

}


//

function filesFindMandatoryMap( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      module1 :
      {
        amid :
        {
          dir :
          {
            'terminal' : 'module1/amid/dir/terminal',
          }
        },
      },
      module2 :
      {
      },
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var prefixPath = routinePath + '/src';

  var filePath =
  {
    "module1" : `.`,
    "module1/amid" : `.`,
    "module1/amid/dir" : `.`,
    "module1/amid/dir/terminal" : `.`,
    "module2" : `.`,
    "module2/amid" : `.`
  }

  var basePath =
  {
    "module1" : `module1`,
    "module1/amid" : `module1`,
    "module1/amid/dir" : `module1`,
    "module1/amid/dir/terminal" : `module1`,
    "module2" : `module2`,
    "module2/amid" : `module2`,
  }

  /**/

  var o1 =
  {
    filter :
    {
      prefixPath,
      filePath,
      basePath,
    },
    includingDirs : 1,
    includingTerminals : 1,
    outputFormat : 'absolute',
  }

  /**/

  test.case = 'default';
  var o2 = _.mapExtend( null, o1 );
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir/terminal',
    'src/module2',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:0 mandatory:0 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 0;
  o2.mandatory = 0;
  o2.includingDefunct = 0;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module2',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:0 mandatory:0 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 0;
  o2.mandatory = 0;
  o2.includingDefunct = 1;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module2',
    'src/module2/amid',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:0 mandatory:1 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 0;
  o2.mandatory = 1;
  o2.includingDefunct = 0;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs
    ([
      'src/module1',
      'src/module1/amid',
      'src/module1/amid/dir',
      'src/module1/amid/dir/terminal',
      'src/module2',
    ]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'recursive:0 mandatory:1 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 0;
  o2.mandatory = 1;
  o2.includingDefunct = 1;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs
    ([
      'src/module1',
      'src/module1/amid',
      'src/module1/amid/dir',
      'src/module1/amid/dir/terminal',
      'src/module2',
      'src/module2/amid',
    ]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'recursive:1 mandatory:0 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 1;
  o2.mandatory = 0;
  o2.includingDefunct = 0;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir/terminal',
    'src/module2',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:1 mandatory:0 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 1;
  o2.mandatory = 0;
  o2.includingDefunct = 1;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir/terminal',
    'src/module2',
    'src/module2/amid',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:1 mandatory:1 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 1;
  o2.mandatory = 1;
  o2.includingDefunct = 0;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs
    ([
      'src/module1',
      'src/module1/amid',
      'src/module1/amid',
      'src/module1/amid/dir',
      'src/module1/amid/dir',
      'src/module1/amid/dir/terminal',
      'src/module1/amid/dir/terminal',
      'src/module2',
    ]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'recursive:1 mandatory:1 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 1;
  o2.mandatory = 1;
  o2.includingDefunct = 1;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
    var expected = abs
    ([
      'src/module1',
      'src/module1/amid',
      'src/module1/amid',
      'src/module1/amid/dir',
      'src/module1/amid/dir',
      'src/module1/amid/dir/terminal',
      'src/module1/amid/dir/terminal',
      'src/module2',
    ]);
    test.identical( found, expected );
  });

  /**/

  test.case = 'recursive:2 mandatory:0 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 2;
  o2.mandatory = 0;
  o2.includingDefunct = 0;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir/terminal',
    'src/module2',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:2 mandatory:0 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 2;
  o2.mandatory = 0;
  o2.includingDefunct = 1;
  var found = provider.filesFind( o2 );
  var expected = abs
  ([
    'src/module1',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir',
    'src/module1/amid/dir/terminal',
    'src/module1/amid/dir/terminal',
    'src/module2',
    'src/module2/amid',
  ]);
  test.identical( found, expected );

  /**/

  test.case = 'recursive:2 mandatory:1 includingDefunct:0';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 2;
  o2.mandatory = 1;
  o2.includingDefunct = 0;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
  });

  /**/

  test.case = 'recursive:2 mandatory:1 includingDefunct:1';
  var o2 = _.mapExtend( null, o1 );
  o2.recursive = 2;
  o2.mandatory = 1;
  o2.includingDefunct = 1;
  test.shouldThrowErrorSync( () =>
  {
    var found = provider.filesFind( o2 );
  });

  /* - */

} /* end of filesFindMandatoryMap */

//

function filesFindExcluding( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  test.open( 'node_modules' );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'package.json' : '/dir2/package.json',
      'node_modules' : '/node_modules',
      dir1 :
      {
        t1 : '/dir1/t1',
        t2 : '/dir1/t2',
        dir11 : { t3 : '/dir1/dir11/t3' },
        node_modules :
        {
          t2 : '/dir1/node_modules/t2',
          dir11 : { t3 : '/dir1/node_modules/dir11/t3' },
        },
      },
      dir2 :
      {
        t21 : '/dir2/t21',
        'package.json' : '/dir2/package.json',
        node_modules :
        {
          t2 : '/dir2/node_modules/t2',
          dir11 : { t3 : '/dir2/node_modules/dir11/t3' },
        },
      },
    },
  });

  extract1.filesReflectTo( provider, routinePath );

  /* */

  test.case = 'bools, no glob';

  var find = provider.filesFinder
  ({
    recursive : 2,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      filePath : { 'node_modules' : 0, 'package.json' : 0 },
    }
  });

  var expected = [ './dir1/t1', './dir1/t2', './dir1/dir11/t3', './dir1/node_modules/t2', './dir1/node_modules/dir11/t3', './dir2/package.json', './dir2/t21', './dir2/node_modules/t2', './dir2/node_modules/dir11/t3' ];
  var got = find( routinePath );
  test.identical( got, expected );

  /* */

  test.case = 'bools, glob';

  var find = provider.filesFinder
  ({
    recursive : 2,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      filePath : { '**/node_modules/**' : 0, '**/package.json' : 0 },
    }
  });

  var expected = [ './dir1/t1', './dir1/t2', './dir1/dir11/t3', './dir2/t21' ];
  var got = find( routinePath );
  test.identical( got, expected );

  /* */

  test.case = 'bools, glob, include all';

  var find = provider.filesFinder
  ({
    recursive : 2,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    maskPreset : 0,
    outputFormat : 'relative',
    filter :
    {
      filePath : { '**/node_modules/**' : 0, '**/package.json' : 0 },
    }
  });

  /*
    zzz : extend optimization "certainly"
  */

  var expected = [ '.', './dir1', './dir1/t1', './dir1/t2', './dir1/dir11', './dir1/dir11/t3', './dir2', './dir2/t21' ];
  var got = find( routinePath );
  test.identical( got, expected );

  /* - */

  test.close( 'node_modules' );

  test.open( '+*' );

  /* - */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      '+t' : '/+t',
      't' : '/t',
      '+ter' : '/+ter',
      'ter' : '/ter',
      '+dir1' :
      {
        '+t' : '/+t',
        't' : '/t',
        '+ter' : '/+ter',
        'ter' : '/ter',
      },
      dir2 :
      {
        dir3 :
        {
          '+t' : '/+t',
          't' : '/t',
          '+ter' : '/+ter',
          'ter' : '/ter',
        },
        '+dir4' :
        {
          '+t' : '/+t',
          't' : '/t',
          '+ter' : '/+ter',
          'ter' : '/ter',
        },
      },
    },
  });

  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    recursive : 2,
    maskPreset : 0,
    outputFormat : 'relative',
  });

  /* */

  test.case = 'control';
  var expectedRelative =
  [
    './+t',
    './+ter',
    './t',
    './ter',
    './+dir1/+t',
    './+dir1/+ter',
    './+dir1/t',
    './+dir1/ter',
    './dir2/+dir4/+t',
    './dir2/+dir4/+ter',
    './dir2/+dir4/t',
    './dir2/+dir4/ter',
    './dir2/dir3/+t',
    './dir2/dir3/+ter',
    './dir2/dir3/t',
    './dir2/dir3/ter'
  ]
  var gotRelative = find({ filePath : { [abs( '.' )] : '' } });
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'control';
  var expectedRelative =
  [
    './t',
    './ter',
    './+dir1/+t',
    './+dir1/+ter',
    './+dir1/t',
    './+dir1/ter',
    './dir2/+dir4/+t',
    './dir2/+dir4/+ter',
    './dir2/+dir4/t',
    './dir2/+dir4/ter',
    './dir2/dir3/+t',
    './dir2/dir3/+ter',
    './dir2/dir3/t',
    './dir2/dir3/ter'
  ]
  var gotRelative = find({ filePath : { [abs( '.' )] : '', '+*' : 0 } });
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = '+**';
  var expectedRelative =
  [
    './t',
    './ter',
    './dir2/+dir4/+t',
    './dir2/+dir4/+ter',
    './dir2/+dir4/t',
    './dir2/+dir4/ter',
    './dir2/dir3/+t',
    './dir2/dir3/+ter',
    './dir2/dir3/t',
    './dir2/dir3/ter'
  ]
  var gotRelative = find({ filePath : { [abs( '.' )] : '', '+**' : 0 } });
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( '+*' );

} /* end of filesFindExcluding */

//

function filesFindGlobLogic( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /* - */

  test.open( 'logic' );

  /* - */

  test.case = 'mixed, only stem';
  var expectedRelative = [ '.', './f.js', './f.test.js', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.test.js' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**.js**' : '',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'mixed, several stems';
  var expectedRelative = [ '..', '.', './f.js', './f.test.js', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.test.js', '../proto2', '../proto2/f.ss', '../proto2/f.test.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**.js**' : '',
    './src/proto**.ss**' : '',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'mixed, several stems';
  // var expectedRelative = [ '..', '.', './f.js', './f.test.js', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.test.js', '../proto2', '../proto2/f.ss', '../proto2/f.test.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.ss' ];
  var expectedRelative = [ '.', './proto', './proto/f.ss', './proto/f.test.ss', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.ss', './proto2', './proto2/f.ss', './proto2/f.test.ss', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.ss', './src/proto', './src/proto/f.js', './src/proto/f.test.js', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.test.js' ]
  var basePath = abs
  ({
    './src/proto/**.js**' : abs( '.' ),
    './src/proto**.ss**' : abs( 'src' ),
  });
  var filePath = abs
  ({
    './src/proto/**.js**' : '',
    './src/proto**.ss**' : '',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'include js';
  var expectedRelative = [ '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude tests, include js';

  var expectedRelative = [ '.', './f.js', './f.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.test*' : false,
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude tests2, include js';

  var expectedRelative = [ '.', './f.js', './f.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.test*' : false,
    './src/**.test/**' : false,
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude bools, several include bool';

  // var expectedRelative = [ '.', './f.js', './f.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss' ];
  var expectedRelative = [ '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.test*' : false,
    './src/**.test/**' : false,
    './src/**.js' : true,
    './src/**.s' : true,
    './src/**.ss' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude bools';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**' : '',
    './src/**.test*' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude bool, overlaping non-bools';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/file', '../proto2', '../proto2/f.js', '../proto2/f.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**' : '',
    './src/**.test*' : false,
    './src/**.js' : '',
    './src/**.s' : '',
    './src/**.ss' : '',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'exclude bools, 3 overlaping non-bool, 1 include bool';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**' : true,
    './src/**.test*' : false,
    './src/**.js' : '',
    './src/**.s' : '',
    './src/**.ss' : '',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'logic' );

}

//

function filesFindGlobComplex( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /* - */

  test.open( 'negative is below' );

  /* - */

  test.case = 'control1';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/dir1/dir2/**' : './out',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'control2';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/dir1/dir2/**' : './out',
    './**protx**' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = 'main';

  var expectedRelative = [];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/dir1/dir2/**' : './out',
    './**proto**' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'negative is below' );
  test.open( 'split with several dual-asterisks' );

  /* - */

  test.case = 'complex glob';

  var expectedRelative = [ '.', './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/**di**r2**' : './out',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = './**src**dir2** control1';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/**' : './out',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = './**src**dir2**, control2';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/**' : './out',
    './**srcx**dir2**' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = './**src**dir2** : false';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/**' : './out',
    './**src**dir2**' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* */

  test.case = './**src**dir2** : true';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = null;
  var filePath = abs
  ({
    './src/proto/**' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'split with several dual-asterisks' );

  test.open( '**?' );

  /* - */

  test.case = 'src/proto**';
  var expectedRelative = [ '.', './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/f.cc', './proto2/f.js', './proto2/f.ss', './proto2/f.test.js', './proto2/f.test.ss', './proto2/file', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var records = find( abs( 'src/proto**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/proto**?';
  var expectedRelative = [ '.', './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/f.cc', './proto2/f.js', './proto2/f.ss', './proto2/f.test.js', './proto2/f.test.ss', './proto2/file', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var records = find( abs( 'src/proto**?' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/proto**????';
  var expectedRelative = [ '.', './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/f.cc', './proto2/f.js', './proto2/f.ss', './proto2/f.test.js', './proto2/f.test.ss', './proto2/file', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var records = find( abs( 'src/proto**????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/proto**?????';
  var expectedRelative = [ '.', './proto', './proto/f.test.js', './proto/f.test.ss', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto2', './proto2/f.test.js', './proto2/f.test.ss', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss' ];
  var records = find( abs( 'src/proto**?????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/proto**??????????';
  var expectedRelative = [ '.', './proto', './proto/dir1', './proto/dir1/dir2', './proto2', './proto2/dir1', './proto2/dir1/dir2' ];
  var records = find( abs( 'src/proto**??????????' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( '**?' );
  test.open( '/ after **' );

  /* - */

  test.case = 'src/**/2/**';
  var expectedRelative = [ '.', './proto', './proto/dir1', './proto/dir1/dir2', './proto2', './proto2/dir1', './proto2/dir1/dir2' ];
  var records = find( abs( 'src/**/2/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/**2/**';
  var expectedRelative = [ '.', './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/f.cc', './proto2/f.js', './proto2/f.ss', './proto2/f.test.js', './proto2/f.test.ss', './proto2/file', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var records = find( abs( 'src/**2/**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'src/**2**';
  var expectedRelative = [ '.', './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file', './proto2', './proto2/f.cc', './proto2/f.js', './proto2/f.ss', './proto2/f.test.js', './proto2/f.test.ss', './proto2/file', './proto2/dir1', './proto2/dir1/dir2', './proto2/dir1/dir2/f.cc', './proto2/dir1/dir2/f.js', './proto2/dir1/dir2/f.ss', './proto2/dir1/dir2/f.test.js', './proto2/dir1/dir2/f.test.ss', './proto2/dir1/dir2/file' ];
  var records = find( abs( 'src/**2**' ) );
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( '/ after **' );

} /* end of filesFindGlobComplex */

//

function filesFindAnyPositive( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /* - */

  test.open( 'filePath=src/proto, basePath=src/proto' );

  /* - */

  test.case = 'filter=*/?.(js|s|ss)';

  var expectedRelative = [];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.js', './f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.js', './f.ss', './dir1' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '.' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto' );

  test.open( 'filePath=src, basePath=src/proto' );

  /* - */

  test.case = 'filter=*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './dir1', '../proto2', '../proto2/f.js', '../proto2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './dir1' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '.' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/f.js', '../proto2/f.ss', '../proto2/dir1' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=src/proto' );

  test.open( 'filePath=src, basePath=.' );

  /* - */

  test.case = 'filter=*/?.(js|s|ss)';

  var expectedRelative = [ './src' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.js', './src/proto/f.ss', './src/proto2', './src/proto2/f.js', './src/proto2/f.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.js', './src/proto/f.ss', './src/proto/dir1' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/dir1' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=.' );

  test.open( 'filePath=src/proto, basePath=src' );

  /* - */

  test.case = 'filter=*/?.(js|s|ss)';

  var expectedRelative = [];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.js', './proto/f.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.js', './proto/f.ss', './proto/dir1' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './proto' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src' );

  test.open( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

  test.case = 'filter=*/?.(js|s|ss)';

  var expectedRelative = [];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.js', '../../proto/f.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.js', '../../proto/f.ss', '../../proto/dir1' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/*/?.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/*/?.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

} /* end of filesFindAnyPositive */

//

function filesFindTotalPositive( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /* - */

  test.open( 'filePath=src/proto, basePath=src/proto' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto' );
  test.open( 'filePath=src, basePath=src/proto' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', '../proto2', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', '../proto2', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.js', './f.ss', './f.test.js', './f.test.ss', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '../proto2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=src/proto' );

  test.open( 'filePath=src, basePath=.' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto2', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto2', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=.' );
  test.open( 'filePath=src/proto, basePath=src' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src' );
  test.open( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

} /* end of filesFindTotalPositive */

//

function filesFindSeveralTotalPositive( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /* - */

  test.open( 'filePath=src/proto, basePath=src/proto' );

  /* - */

  test.case = 'filter=**srcx**dir2**';

  var expectedRelative = [ '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**srcx**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  test.case = 'filter=**src**dir2**';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**dir1**dir2**';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**dir1**dir2**';

  var expectedRelative = [ '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto' );

  test.open( 'filePath=src, basePath=src/proto' );

  /* - */

  test.case = 'filter=**src**dir2**';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**dir1**dir2**';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**dir1**dir2**';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**dir1**dir2**';

  var expectedRelative = [ '..', '.', './dir1', './dir1/dir2' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**dir1**dir2**';

  var expectedRelative = [ '..', '../proto2', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=src/proto' );

  test.open( 'filePath=src, basePath=.' );

  /* - */

  test.case = 'filter=**src**dir2**';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**proto**dir2**';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**proto**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**dir1**dir2**';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**dir1**dir2**';

  var expectedRelative = [ './src', './src/proto', './src/proto/dir1', './src/proto/dir1/dir2' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**dir1**dir2**';

  var expectedRelative = [ './src', './src/proto2', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=.' );

  test.open( 'filePath=src/proto, basePath=src' );

  /* - */

  test.case = 'filter=**src**dir2**';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**proto**dir2**';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**proto**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**dir1**dir2**';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**dir1**dir2**';

  var expectedRelative = [ './proto', './proto/dir1', './proto/dir1/dir2' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src' );
  test.open( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

  test.case = 'filter=**src**dir2**';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**src**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**proto**dir2**';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**proto**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**dir1**dir2**';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**dir1**dir2**';

  var expectedRelative = [ '../../proto', '../../proto/dir1', '../../proto/dir1/dir2' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**dir1**dir2**' : true,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

} /* end of filesFindSeveralTotalPositive */

//

function filesFindTotalNegative( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* - */

  var tree =
  {
    src :
    {
      proto :
      {
        '-ile' : 'src/proto/-ile',
        'file' : 'src/proto/file',
        'f.cc' : 'src/proto/f.cc',
        'f.js' : 'src/proto/f.js',
        'f.ss' : 'src/proto/f.ss',
        'f.test.js' : 'src/proto/f.test.js',
        'f.test.ss' : 'src/proto/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto/-ile',
            'file' : 'dir1/dir2/src/proto/file',
            'f.cc' : 'dir1/dir2/src/proto/f.cc',
            'f.js' : 'dir1/dir2/src/proto/f.js',
            'f.ss' : 'dir1/dir2/src/proto/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto/f.test.ss',
          }
        }
      },
      proto2 :
      {
        '-ile' : 'src/proto2/-ile',
        'file' : 'src/proto2/file',
        'f.cc' : 'src/proto2/f.cc',
        'f.js' : 'src/proto2/f.js',
        'f.ss' : 'src/proto2/f.ss',
        'f.test.js' : 'src/proto2/f.test.js',
        'f.test.ss' : 'src/proto2/f.test.ss',
        dir1 :
        {
          dir2 :
          {
            '-ile' : 'dir1/dir2/src/proto2/-ile',
            'file' : 'dir1/dir2/src/proto2/file',
            'f.cc' : 'dir1/dir2/src/proto2/f.cc',
            'f.js' : 'dir1/dir2/src/proto2/f.js',
            'f.ss' : 'dir1/dir2/src/proto2/f.ss',
            'f.test.js' : 'dir1/dir2/src/proto2/f.test.js',
            'f.test.ss' : 'dir1/dir2/src/proto2/f.test.ss',
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });

  provider.filesDelete( routinePath );
  extract.filesReflectTo( provider, routinePath );

  var find = provider.filesFinder
  ({
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    recursive : 2,
    filter :
    {
      prefixPath : routinePath,
    }
  });

  /**/

  test.case = 'control check';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**' : './out',
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.open( 'filePath=src/proto, basePath=src/proto' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto/**' : './out',
    './**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto' );
  test.open( 'filePath=src, basePath=src/proto' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '..', '.', './f.cc', './f.js', './f.ss', './f.test.js', './f.test.ss', './file', './dir1', './dir1/dir2', './dir1/dir2/f.cc', './dir1/dir2/f.js', './dir1/dir2/f.ss', './dir1/dir2/f.test.js', './dir1/dir2/f.test.ss', './dir1/dir2/file', '../proto2', '../proto2/f.cc', '../proto2/f.js', '../proto2/f.ss', '../proto2/f.test.js', '../proto2/f.test.ss', '../proto2/file', '../proto2/dir1', '../proto2/dir1/dir2', '../proto2/dir1/dir2/f.cc', '../proto2/dir1/dir2/f.js', '../proto2/dir1/dir2/f.ss', '../proto2/dir1/dir2/f.test.js', '../proto2/dir1/dir2/f.test.ss', '../proto2/dir1/dir2/file' ];
  var basePath = abs( 'src/proto' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=src/proto' );

  test.open( 'filePath=src, basePath=.' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './src', './src/proto', './src/proto/f.cc', './src/proto/f.js', './src/proto/f.ss', './src/proto/f.test.js', './src/proto/f.test.ss', './src/proto/file', './src/proto/dir1', './src/proto/dir1/dir2', './src/proto/dir1/dir2/f.cc', './src/proto/dir1/dir2/f.js', './src/proto/dir1/dir2/f.ss', './src/proto/dir1/dir2/f.test.js', './src/proto/dir1/dir2/f.test.ss', './src/proto/dir1/dir2/file', './src/proto2', './src/proto2/f.cc', './src/proto2/f.js', './src/proto2/f.ss', './src/proto2/f.test.js', './src/proto2/f.test.ss', './src/proto2/file', './src/proto2/dir1', './src/proto2/dir1/dir2', './src/proto2/dir1/dir2/f.cc', './src/proto2/dir1/dir2/f.js', './src/proto2/dir1/dir2/f.ss', './src/proto2/dir1/dir2/f.test.js', './src/proto2/dir1/dir2/f.test.ss', './src/proto2/dir1/dir2/file' ];
  var basePath = abs( '.' );
  var filePath = abs
  ({
    './src' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src, basePath=.' );

  test.open( 'filePath=src/proto, basePath=src' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ './proto', './proto/f.cc', './proto/f.js', './proto/f.ss', './proto/f.test.js', './proto/f.test.ss', './proto/file', './proto/dir1', './proto/dir1/dir2', './proto/dir1/dir2/f.cc', './proto/dir1/dir2/f.js', './proto/dir1/dir2/f.ss', './proto/dir1/dir2/f.test.js', './proto/dir1/dir2/f.test.ss', './proto/dir1/dir2/file' ];
  var basePath = abs( 'src' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src' );

  test.open( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

  test.case = 'filter=**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir1/dir2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir1/dir2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /**/

  test.case = 'filter=src/proto2/dir3/**.(js|s|ss)';

  var expectedRelative = [ '../../proto', '../../proto/f.cc', '../../proto/f.js', '../../proto/f.ss', '../../proto/f.test.js', '../../proto/f.test.ss', '../../proto/file', '../../proto/dir1', '../../proto/dir1/dir2', '../../proto/dir1/dir2/f.cc', '../../proto/dir1/dir2/f.js', '../../proto/dir1/dir2/f.ss', '../../proto/dir1/dir2/f.test.js', '../../proto/dir1/dir2/f.test.ss', '../../proto/dir1/dir2/file' ];
  var basePath = abs( 'src/proto2/proto3' );
  var filePath = abs
  ({
    './src/proto' : './out',
    './src/proto2/dir3/**.(js|s|ss)' : false,
  });
  var records = find({ filter : { filePath, basePath } });
  var gotRelative = _.select( records, '*/relative' );
  test.identical( gotRelative, expectedRelative );

  /* - */

  test.close( 'filePath=src/proto, basePath=src/proto2/proto3' );

  /* - */

} /* end of filesFindTotalNegative */

//

/*
qqq : extend coverage of filesFindGroups
qqq : please, clean filesFindGroups
*/

function filesFindGroups( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  var filesTree =
  {
    'a.js' : 'a.js',
    'b.js' : 'b.js',
    'a.txt' : 'a.txt',
    'b.txt' : 'b.txt',
    'dir' :
    {
      'a.js' : 'dir/a.js',
      'b.js' : 'dir/b.js',
      'a.txt' : 'dir/a.txt',
      'b.txt' : 'dir/b.txt',
    }
  }

  var extract1 = new _.FileProvider.Extract({ filesTree : filesTree });
  extract1.filesReflectTo( provider, routinePath );

  var expected =
  {
    'pathsGrouped' :
    {
      [ abs( 'Produced.txt' ) ] : { [ abs( '**.txt' ) ] : '' },
      [ abs( 'Produced.js' ) ] : { [ abs( '**.js' ) ] : '' }
    },
    'filesGrouped' :
    {
      [ abs( 'Produced.txt' ) ] :
      [
        './a.txt', './b.txt', './dir/a.txt', './dir/b.txt'
      ],
      [ abs( 'Produced.js' ) ] :
      [
        './a.js', './b.js', './dir/a.js', './dir/b.js'
      ]
    },
    'srcFiles' :
    {
      './a.txt' : './a.txt',
      './b.txt' : './b.txt',
      './dir/a.txt' : './dir/a.txt',
      './dir/b.txt' : './dir/b.txt',
      './a.js' : './a.js',
      './b.js' : './b.js',
      './dir/a.js' : './dir/a.js',
      './dir/b.js' : './dir/b.js',
    },
    'errors' : [],
    'options' : true,
  }

  var filePath =
  {
    '**.txt' : 'Produced.txt',
    '**.js' : 'Produced.js',
  }
  var src =
  {
    filePath : filePath,
    prefixPath : routinePath,
  }
  var dst =
  {
    prefixPath : routinePath,
  }

  /* tests */

  test.case = 'default settings';
  debugger;
  var found = provider.filesFindGroups({ src, dst, outputFormat : 'relative' });
  debugger;
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'mandatory : 1';
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    mandatory : 1,
  }
  var found = provider.filesFindGroups( map );
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'mandatory : 0';
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    mandatory : 0,
  }
  var found = provider.filesFindGroups( map ); /* qqq : bad naming! */
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'sync : 0';
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    sync : 0,
  }
  var found = provider.filesFindGroups( map );
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'mode : legacy';
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    mode : 'legacy',
  }
  var found = provider.filesFindGroups( map );
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'recursive : 1, mandatory : 0';
  var expected =
  {
    'pathsGrouped' :
    {
      [ abs( 'Produced.txt' ) ] : { [ abs( '**.txt' ) ] : '' },
      [ abs( 'Produced.js' ) ] : { [ abs( '**.js' ) ] : '' }
    },
    'filesGrouped' :
    {
      [ abs( 'Produced.txt' ) ] :
      [
        './a.txt', './b.txt'
      ],
      [ abs( 'Produced.js' ) ] :
      [
        './a.js', './b.js'
      ]
    },
    'srcFiles' :
    {
      './a.txt' : './a.txt',
      './b.txt' : './b.txt',
      './a.js' : './a.js',
      './b.js' : './b.js',
    },
    'errors' : [],
    'options' : true,
  }
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    recursive : 1,
  }
  var found = provider.filesFindGroups( map );
  found.options = !!found.options;
  test.identical( found, expected );


  test.case = 'recursive : 0';
  var expected =
  {
    'pathsGrouped' :
    {
      [ abs( 'Produced.txt' ) ] : { [ abs( '**.txt' ) ] : '' },
      [ abs( 'Produced.js' ) ] : { [ abs( '**.js' ) ] : '' }
    },
    'filesGrouped' :
    {
      [ abs( 'Produced.txt' ) ] : [],
      [ abs( 'Produced.js' ) ] : [],
    },
    'srcFiles' :
    {
    },
    'errors' : [],
    'options' : true,
  }
  var map =
  {
    src,
    dst,
    outputFormat : 'relative',
    recursive : 0,
    mandatory : 0,
  }
  var found = provider.filesFindGroups( map );
  found.options = !!found.options;
  test.identical( found, expected );

  /* - */

  if( Config.debug )
  {
    test.case = 'recursive : 0, mandatory : 1';
    test.shouldThrowErrorSync( () =>
    {
      var map =
      {
        src,
        dst,
        outputFormat : 'relative',
        recursive : 0,
        mandatory : 1,
      }
      var found = provider.filesFindGroups( map );
      found.options = !!found.options;
      test.identical( found, expected );
    });
  }

}

//

function filesReflectEvaluate( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        a : 'dir/a',
        b : 'dir/b',
        c :
        {
          a : 'dir/c/a'
        }
      }
    },
  });

  test.case = 'setup';
  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );

  var o1 =
  {
    src : abs( './dir' ),
    dst : abs( './dir/dst' ),
  }

  var records = provider.filesReflectEvaluate( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedSrcRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var extract2 = provider.filesExtract( routinePath );
  extract2.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    extract2.fileWrite( r.absolute, extract2.fileRead( r.absolute ) );
  }})
  test.identical( extract2.filesTree, extract1.filesTree );

}

//

function filesReflectTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'deleting enabled, included files should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst',
    },
    filter :
    {
      maskAll : { includeAny : /file2$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file2 : 'file2', dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file2' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, false, true ];
  var expectedPreserve = [ true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'deleting enabled, no filter';

  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    dst : { file : 'file', file2 : 'file2' }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'deleting disabled, separate filters'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    src :
    {
      maskAll : { excludeAny : 'file' }
    },
    dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst' ];
  var expectedSrcAbsolute = [ '/src' ];

  var expectedAction = [ 'dirMake' ];
  var expectedAllow = [ true ];
  var expectedPreserve = [ true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'deleting enabled, separate filters'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } },
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    src :
    {
      maskAll : { excludeAny : 'file' }
    },
    dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : {},
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/file', '/dst/dir/file2' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/file', '/src/dir/file2' ];

  var expectedAction = [ 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'src deleting enabled, no filter, all files from src should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    dst :
    {
      file : 'file',
      file2 : 'file2',
      dir : { file : 'file', file2 : 'file2' }
    }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'dst deleting enabled, no filter, all files from dst should be deleted'
  var tree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { dir : { file : 'file', file2 : 'file2' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file', file2 : 'file2' },
    dst : { file : 'file', file2 : 'file2' }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'deleting enabled, filtered files in dst are preserved'
  var tree =
  {
    src : { file2 : 'file2' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dst :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'dstDeleting:1 srcDeleting:0 dst only'
  var tree =
  {
    src : { file2 : 'file2' },
    dst : { dir : { file : 'file' } }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dst :
    {
      maskAll : { includeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { file2 : 'file2' },
    dst : { file2 : 'file2' },
  }
  test.identical( extract.filesTree, expectedTree )

  var expectedDstAbsolute = [ '/dst', '/dst/file2', '/dst/dir', '/dst/dir/file' ];
  var expectedSrcAbsolute = [ '/src', '/src/file2', '/src/dir', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'src contains filtered file, directory must be preserved'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    src :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, src excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    src :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, dst excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    dst :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, common filter excludes file'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    filter :
    {
      maskAll : { excludeAny : 'file' }
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree )

  /* */

  test.case = 'deleting disabled, no filters'
  var tree =
  {
    src : { file : 'file' },
    dst : { dir : { file : 'file'} }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    srcDeleting : 0,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { file : 'file' },
    dst : { file : 'file', dir : { file : 'file'} }
  }
  test.identical( extract.filesTree, expectedTree );

  /* */

  test.case = 'try to rewrite file.b, file should not be deleted, filter points only to file.a'
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c'
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    includingDirs : 1,
    dstRewriting : 1,
    src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  test.mustNotThrowError( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c'
    }
  }
  test.identical( extract.filesTree, expectedTree );

  /*  */

  test.case = 'dst/srcfile-dstdir should not be deleted';
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    dstRewriting : 1,
    src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 0,
    includingDst : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflect( o )

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  test.identical( extract.filesTree, expectedTree );

  /*  */

  test.case = 'dst/srcfile-dstdir should be deleted';
  var tree =
  {
    src :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
      'file.b' : 'file.c',
      'srcfile-dstdir' : { 'file' : 'file' }
    }
  }
  var o =
  {
    reflectMap :
    {
      '/src' : '/dst'
    },
    writing : 1,
    dstRewriting : 1,
    src : { ends : '.a' },
    srcDeleting : 1,
    dstDeleting : 1,
    includingDst : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflect( o )

  var expectedTree =
  {
    src :
    {
      'file.b' : 'file.b',
      'srcfile-dstdir' : 'x'
    },
    dst :
    {
      'file.a' : 'file.a',
    }
  }
  test.identical( extract.filesTree, expectedTree );

  //

  var tree =
  {
    'src' :
    {
      'dir' :
      {
        a : 'a'
      },
    },
    'dst' :
    {
      'dir' :
      {
        'file' : 'file',
      },
    },
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    src : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    'src' :
    {
      'dir' :
      {
        a : 'a',
      },
    },
    'dst' :
    {
      'dir' :
      {
        'file' : 'file',
      },
    },
  }
  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/file' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileDelete' ];
  var expectedAllow = [ true, true, false ];
  var expectedPreserve = [ true, true, false ];
  var expectedSrcAction = [ 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( srcAction, expectedSrcAction );
  test.identical( srcAllow, expectedSrcAllow );
  test.identical( reason, expectedReason );

  /**/

  var tree =
  {
    'src' :
    {
      'dir' :
      {
        'b.b' : 'b',
        'file' : { a : 'a' }
      },
    },
    'dst' :
    {
      'dir' :
      {
        'b.b' : 'c',
        'file' : 'file',
      },
    },
  }

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    src : { ends : '.b' },
    includingDst : 1,
    includingTerminals : 1,
    includingDirs : 1,
    recursive : 2,
    writing : 1,
    dstRewriting : 1,
    dstDeleting : 0,
    srcDeleting : 1,
    dstRewritingByDistinct : 0
  }
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    'src' :
    {
      'dir' :
      {
        'file' : { a : 'a' }
      },
    },
    'dst' :
    {
      'dir' :
      {
        'b.b' : 'b',
        'file' : 'file',
      },
    },
  }

  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/b.b', '/dst/dir/file' ]
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b.b', '/src/dir/file' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileDelete' ];
  var expectedAllow = [ true, true, true, false ];
  var expectedPreserve = [ true, true, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete', null ];
  var expectedSrcAllow = [ false, true, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( srcAction, expectedSrcAction );
  test.identical( srcAllow, expectedSrcAllow );
  test.identical( reason, expectedReason );

  // //
  //
  // test.case = 'onUp should return original record'
  // var tree =
  // {
  //   'src' :
  //   {
  //      a : 'a',
  //      b : 'b'
  //   },
  //   'dst' :
  //   {
  //   },
  // }
  //
  // function onUp1( record )
  // {
  //   debugger;
  //   record.dst.absolute = record.dst.absolute + '.ext';
  //   return {};
  //   return null;
  // }
  //
  // var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  // var o =
  // {
  //   reflectMap : { '/src' : '/dst' },
  //   onUp : onUp1,
  //   includingDst : 0,
  //   includingTerminals : 1,
  //   includingDirs : 0,
  //   recursive : 2,
  //   writing : 1,
  //   srcDeleting : 0,
  //   linking : 'nop'
  // }
  //
  // test.shouldThrowError( () => extract.filesReflect( o ) );
  // test.identical( extract.filesTree, tree );
  //
  // debugger; return;
  //
  // //

  test.case = 'onUp changes dst path'
  var tree =
  {
    'src' :
    {
       a : 'a',
       b : 'b'
    },
    'dst' :
    {
    },
  }

  var expectedTree =
  {
    'src' :
    {
       a : 'a',
       b : 'b'
    },
    'dst' :
    {
      'a.ext' : 'a',
      'b.ext' : 'b'
    },
  }

  function onUp2( record )
  {
    record.dst.absolute = record.dst.absolute + '.ext';
    return record;
  }

  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onUp : onUp2,
    includingDst : 0,
    includingTerminals : 1,
    includingDirs : 0,
    recursive : 2,
    writing : 1,
    srcDeleting : 0,
    // linking : 'nop'
  }

  extract.filesReflect( o );
  test.identical( extract.filesTree, expectedTree );

  //

  test.case = 'linking : nop, dst files will be deleted for rewriting after onWriteDstUp call'
  var tree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'dst',
      a1 : 'dst',
    },
  }

  function onWriteDstUp1( record )
  {
    if( !record.dst.isDir )
    record.dst.factory.hubFileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return record;
  }

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp1,
    src : { maskTerminal : { includeAny : 'a' } },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  extract.filesReflect( o )
  var expectedTree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'onWriteDstUp',
      a1 : 'onWriteDstUp',
    }
  }

  test.identical( extract.filesTree, expectedTree );

  //

  test.case = 'linking : nop, return _.dont from onWriteDstUp to prevent any action'
  var tree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'dst',
      a1 : 'dst',
    },
  }

  function onWriteDstUp2( record )
  {
    if( !record.dst.isDir )
    record.dst.factory.hubFileProvider.fileWrite( record.dst.absolute, 'onWriteDstUp' );
    return _.dont;
  }

  var extract = _.FileProvider.Extract({ filesTree : tree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    onWriteDstUp : onWriteDstUp2,
    src : { maskTerminal : { includeAny : 'a' } },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 1,
    srcDeleting : 0,
    linking : 'nop'
  }

  extract.filesReflect( o )
  var expectedTree =
  {
    'src' :
    {
      a : 'src',
      a1 : 'src',
    },
    'dst' :
    {
      a : 'onWriteDstUp',
      a1 : 'onWriteDstUp',
    }
  }

  test.identical( extract.filesTree, expectedTree );

}  /* end of filesReflectTrivial */

//

function filesReflectRecursive( test )
{
  var tree =
  {
    src : { a1 : '1', dir1 : { a2 : '2', dir2 : { a3 : '3' } } },
  }

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 0,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : {}
  }
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 1,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : { a1 : '1', dir1 : {} }
  }
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src
  }
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 0,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 1,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  test.identical( provider.filesTree, expected );

  //

  var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });
  var o =
  {
    reflectMap : { '/src/a1' : '/dst' },
    recursive : 2,
    writing : 1,
    dstDeleting : 0,
    dstRewriting : 0,
    srcDeleting : 0,
    includingDirs : 1,
    includingTerminals : 1,
    linking : 'fileCopy'
  }
  provider.filesReflect( o );
  var expected =
  {
    src : tree.src,
    dst : tree.src.a1
  }
  test.identical( provider.filesTree, expected );

  //

  if( Config.debug )
  {
    var provider = _.FileProvider.Extract({ filesTree : _.cloneJust( tree ) });

    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '0' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '1' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : '2' }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : false }) );
    test.shouldThrowError( () => provider.filesReflect({ reflectMap : { '/src' : '/dst' }, recursive : true }) );
  }
}

//

/*
  Cover option otputFormat for routine filesReflect.
*/

/*
qqq : please implement test routine filesFindOutputFormat
*/

function filesReflectOutputFormat( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* setup */

  var tree =
  {
    src :
    {
      file : 'file',
      dir : { file : 'file' },
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree });

  extract.filesReflectTo( provider, routinePath );

  /* */

  test.case = 'default';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
  }

  var found = provider.filesReflect( o );
  var srcAbs = _.select( found, '*/src/absolute' );
  var expected = abs( 'src', [ '.', './file', './dir', './dir/file' ] );
  test.identical( srcAbs, expected );

  /* */

  test.case = 'record';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'record',
  }

  var found = provider.filesReflect( o );
  var srcAbs = _.select( found, '*/src/absolute' );
  var expected = abs( 'src', [ '.', './file', './dir', './dir/file' ] );
  test.identical( srcAbs, expected );

  /* */

  test.case = 'src.relative';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'src.relative',
  }

  var found = provider.filesReflect( o );
  var expected = [ '.', './file', './dir', './dir/file' ];
  test.identical( found, expected );

  /* */

  test.case = 'src.absolute';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'src.absolute',
  }

  var found = provider.filesReflect( o );
  var expected = abs([ './src', './src/file', './src/dir', './src/dir/file' ]);
  test.identical( found, expected );

  /* */

  test.case = 'dst.relative';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src',
    },
    dst :
    {
      prefixPath : routinePath + '/dst',
      basePath : '..',
    },
    mandatory : 1,
    outputFormat : 'dst.relative',
  }

  var found = provider.filesReflect( o );
  var expected = [ './dst', './dst/file', './dst/dir', './dst/dir/file' ];
  test.identical( expected, found );

  /* */

  test.case = 'dst.absolute';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'dst.absolute',
  }

  var found = provider.filesReflect( o );
  var expected = abs([ './dst', './dst/file', './dst/dir', './dst/dir/file' ]);
  test.identical( found, expected );

  /* */

  test.case = 'nothing';

  var o =
  {
    src :
    {
      prefixPath : routinePath + '/src'
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'nothing',
  }

  var found = provider.filesReflect( o );
  var expected = [];
  test.identical( found, expected );

  /* */

}

//

function filesReflectMandatory( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* */

  test.case = 'no dir';

  var tree =
  {
    src :
    {
      module1 :
      {
        amid :
        {
          'terminal' : 'module1/amid/terminal',
        },
      },
      module2 :
      {
      },
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree });

  extract.filesReflectTo( provider, routinePath );

  var prefixPath = routinePath + '/src';

  var filePath =
  {
    "module1" : `.`,
    "module1/amid" : `.`,
    "module1/amid/terminal" : `.`,
    "module2" : `.`,
    "module2/amid" : `.`
  }

  var basePath =
  {
    "module1" : `module1`,
    "module1/amid" : `module1`,
    "module1/amid/terminal" : `module1`,
    "module2" : `module2`,
    "module2/amid" : `module2`,
  }

  var o =
  {
    src :
    {
      prefixPath,
      filePath,
      basePath,
    },
    dst :
    {
      prefixPath : routinePath + '/dst'
    },
    mandatory : 1,
    outputFormat : 'src.relative',
  }


  test.shouldThrowErrorSync( () =>
  {
    debugger;
    var srcRel = provider.filesReflect( o );
    debugger;
    var expRels = [ '.', './amid', './amid/terminal', './amid', './amid/terminal', './amid/terminal', '.' ];
    test.identical( srcRel, expRels );
  });

  /* */

/*
"Filter
  prefixPath :
`/C/pro/web/Dave/git/trunk/builder/include/dwtools/tmp.tmp/Will-154626-16-4c02/relfectSubmodulesWithNotExistingFile/module`
  filePath :
{
  "module1" : `.`,
  "module1/amid" : `.`,
  "module1/amid/terminal" : `.`,
  "module2" : `.`,
  "module2/amid" : `.`
}
  basePath :
{
  "module1" : `module1`,
  "module1/amid" : `module1`,
  "module1/amid/terminal" : `module1`,
  "module2" : `module2`,
  "module2/amid" : `module2`
}"
*/

  debugger; return; xxx
}

//

function filesReflectMutuallyExcluding( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  var precise = true;

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  function filesTreeAdapt( extract )
  {
    //simplifies trees comparison by converting terminals to strings

    if( !( provider instanceof _.FileProvider.HardDrive ) )
    return;

    extract.filesFindRecursive
    ({
      filePath : '/',
      includingTerminals : 1,
      includingDirs : 0,
      includingStem : 0,
      onDown : handleDown
    })

    function handleDown( record )
    {
      extract.fileWrite( record.absolute, extract.fileRead( record.absolute ) )
    }
  }

  /* */

  test.case = 'terminals, no dst, exclude src root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { includeAny : /M$/ }
    },
    dst :
    {
      maskAll : { excludeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src : { src : 'src-src' },
    dst : { srcM : 'srcM-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/srcM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/srcM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ null, 'fileDelete' ];
  var expectedSrcAllow = [ true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'terminals, no dst, exclude dst root'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src' },
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src : { srcM : 'srcM-src' },
    dst : { src : 'src-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/src' ]);
  var expectedSrcAbsolute = abs([ './src', './src/src' ]);
  var expectedAction = [ 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'terminals'
  var tree =
  {
    src : { srcM : 'srcM-src', src : 'src-src', bothM : 'bothM-src', both : 'both-src' },
    dst : { dstM : 'dstM', dst : 'dst', bothM : 'bothM', both : 'both' }
  }
  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src : { srcM : 'srcM-src', bothM : 'bothM-src' },
    dst : { dst : 'dst', both : 'both-src', src : 'src-src' }
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  // [
  //   './dst',
  //   './dst/both',
  //   './dst/src',
  //   './dst/bothM',
  //   './dst/dstM'
  // ]
  // [
  //   './dst',
  //   './dst/both',
  //   './dst/bothM',
  //   './dst/src',
  //   './dst/dst',
  //   './dst/dstM'
  // ]

  // [ 'dirMake', 'fileCopy', 'fileCopy', 'fileDelete', 'fileDelete' ]

/*
'./dst',
'./dst/both',
'./dst/bothM',
'./dst/src',
'./dst/dst',
'./dst/dstM'
*/

  // [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting' ]

  var expectedDstAbsolute = abs([ './dst', './dst/both', './dst/src', './dst/bothM', './dst/dst', './dst/dstM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/both', './src/src', './src/bothM', './src/dst', './src/dstM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileDelete', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', 'fileDelete', null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( reason, expectedReason );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'empty dirs';

  var tree =
  {
    src :
    {
      srcDirM : {}, srcPath : {}, bothDirM : {}, bothDir : {},
    },
    dst :
    {
      dstDirM : {}, dstPath : {}, bothDirM : {}, bothDir : {},
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var found = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'absolute' });
  test.identical( found.length, 11 );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      srcDirM : {}, bothDirM : {},
    },
    dst :
    {
      dstPath : {}, bothDir : {}, srcPath : {},
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/bothDir', './dst/srcPath', './dst/bothDirM', './dst/dstDirM', './dst/dstPath' ]);
  var expectedSrcAbsolute = abs([ './src', './src/bothDir', './src/srcPath', './src/bothDirM', './src/dstDirM', './src/dstPath' ]);
  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'fileDelete', 'ignore' ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];
  var expectedAllow = [ true, true, true, true, true, false ];
  var expectedPreserve = [ true, true, false, false, false, true ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', 'fileDelete', null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var reason = _.select( records, '*/reason' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( reason, expectedReason );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'src dirs with two terms';

  var tree =
  {
    src :
    {
      fM : { term : 'src', termM : 'src' },
      f : { term : 'src', termM : 'src' },
    },
    dst :
    {
      fM : 'dst',
      f : 'dst',
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      fM : { termM : 'src' }, f : { term : 'src', termM : 'src' },
    },
    dst :
    {
      fM : { term : 'src' }, f : 'dst',
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/fM', './dst/fM/term' ]);
  var expectedSrcAbsolute = abs([ './src', './src/fM', './src/fM/term' ]);

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true ];
  var expectedPreserve = [ true, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete' ];
  var expectedSrcAllow = [ false, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );

    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'dst dirs with two terms';

  var tree =
  {
    src :
    {
      dM : 'dst',
      d : 'dst',
    },
    dst :
    {
      dM : { term : 'dst', termM : 'dst' },
      d : { term : 'dst', termM : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      dM : 'dst',
    },
    dst :
    {
      dM : { term : 'dst' },
      d : 'dst',
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/d', './dst/d/term', './dst/d/termM', './dst/dM', './dst/dM/term', './dst/dM/termM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/d', './src/d/term', './src/d/termM', './src/dM', './src/dM/term', './src/dM/termM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'dst dirs with two terms';

  var tree =
  {
    src :
    {
      dM : 'dst', d : 'dst',
    },
    dst :
    {
      dM : { term : 'dst', termM : 'dst' }, d : { term : 'dst', termM : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      dM : 'dst',
    },
    dst :
    {
      dM : { term : 'dst' }, d : 'dst',
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/d', './dst/d/term', './dst/d/termM', './dst/dM', './dst/dM/term', './dst/dM/termM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/d', './src/d/term', './src/d/termM', './src/dM', './src/dM/term', './src/dM/termM' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'dirMake', 'ignore', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, false, true ];
  var expectedPreserve = [ true, false, false, false, true, true, false ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

  /* */

  test.case = 'src dirs with single term';

  var tree =
  {
    src :
    {
      dWithM : { termM : 'src' },
      dWithoutM : { term : 'src' },
      dWith : { termM : 'src' },
      dWithout : { term : 'src' },
    },
    dst :
    {
      dWithM : 'dst',
      dWithoutM : 'dst',
      dWith : 'dst',
      dWithout : 'dst',
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      dWithM : { termM : 'src' },
      dWithoutM : {},
      dWith : { termM : 'src' },
      dWithout : { term : 'src' }
    },
    dst :
    {
      dWithoutM : { term : 'src' },
      dWith : 'dst',
      dWithout : 'dst',
    },
  }
  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  // var expectedDstAbsolute = abs([ './dst', './dst/dWithM', './dst/dWithoutM', './dst/dWithoutM/term' ]);
  var expectedDstAbsolute = abs([ './dst', './dst/dWithoutM', './dst/dWithoutM/term', './dst/dWithM' ]);
  var expectedSrcAbsolute = abs([ './src', './src/dWithoutM', './src/dWithoutM/term', './src/dWithM' ]);

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];
  var expectedSrcAction = [ 'fileDelete', null, 'fileDelete', null ];
  var expectedSrcAllow = [ false, true, true, true ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting' ];
  var expectedDeleteFirst = [ false, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );
  var reason = _.select( records, '*/reason' );
  var deleteFirst = _.select( records, '*/deleteFirst' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );

    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
    test.identical( reason, expectedReason );
    test.identical( deleteFirst, expectedDeleteFirst );
  }

  /* */

  test.case = 'dst dirs with single term';

  var tree =
  {
    src :
    {
      dWithM : 'src',
      dWithoutM : 'src',
      dWith : 'src',
      dWithout : 'src',
    },
    dst :
    {
      dWithM : { termM : 'dst' },
      dWithoutM : { term : 'dst' },
      dWith : { termM : 'dst' },
      dWithout : { term : 'dst' },
    }
  }

  var o =
  {
    reflectMap :
    {
      [ abs( './src' ) ] : abs( './dst' )
    },
    src :
    {
      maskAll : { excludeAny : /M$/ }
    },
    dst :
    {
      maskAll : { includeAny : /M$/ }
    },
    srcDeleting : 1,
    dstDeleting : 1,
  }
  var extract = new _.FileProvider.Extract({ filesTree : tree });
  extract.filesReflectTo( provider, routinePath );
  var records = provider.filesReflect( o );
  var extract2 = provider.filesExtract( routinePath );
  filesTreeAdapt( extract2 );
  provider.filesDelete( routinePath );

  var expectedTree =
  {
    src :
    {
      dWithM : 'src',
      dWithoutM : 'src',
      // dWith : 'src',
      // dWithout : 'src',
    },
    dst :
    {
      // dWithM : { termM : 'dst' },
      dWithoutM : { term : 'dst' },
      // dWith : { termM : 'dst' },
      dWith : 'src',
      // dWithout : { term : 'dst' },
      dWithout : 'src',
    }
  }

  test.identical( extract2.filesTree.src, expectedTree.src );
  test.identical( extract2.filesTree.dst, expectedTree.dst );

  var expectedDstAbsolute = abs([ './dst', './dst/dWith', './dst/dWith/termM', './dst/dWithout', './dst/dWithout/term', './dst/dWithM', './dst/dWithM/termM', './dst/dWithoutM', './dst/dWithoutM/term' ]);
  var expectedSrcAbsolute = abs([ './src', './src/dWith', './src/dWith/termM', './src/dWithout', './src/dWithout/term', './src/dWithM', './src/dWithM/termM', './src/dWithoutM', './src/dWithoutM/term' ]);
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false ];
  var expectedPreserve = [ true, false, false, false, false, false, false, true, true ];
  var expectedSrcAction = [ 'fileDelete', 'fileDelete', null, 'fileDelete', null, null, null, null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var srcAction = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  if( precise )
  {
    test.identical( dstAbsolute, expectedDstAbsolute );
    test.identical( srcAbsolute, expectedSrcAbsolute );
    test.identical( action, expectedAction );
    test.identical( allow, expectedAllow );
    test.identical( preserve, expectedPreserve );
    test.identical( srcAction, expectedSrcAction );
    test.identical( srcAllow, expectedSrcAllow );
  }

}

//

function filesReflectWithFilter( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function prepareSingle()
  {

    var tree = _.FileProvider.Extract
    ({
    });

    return { src : tree, dst : tree, hub : tree };
  }

  function prepareTwo()
  {
    var dst = _.FileProvider.Extract
    ({
      filesTree :
      {
      },
    });
    var src = _.FileProvider.Extract
    ({
      filesTree :
      {
      },
    });
    var hub = new _.FileProvider.Hub({ empty : 1 });
    src.originPath = 'extract+src://';
    dst.originPath = 'extract+dst://';
    hub.providerRegister( src );
    hub.providerRegister( dst );
    return { src : src, dst : dst, hub : hub };
  }

  /* */

  var o =
  {
    prepare : prepareSingle,
  }

  debugger;
  _filesReflectWithFilter.call( context, test, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  _filesReflectWithFilter.call( context, test, o );

}

//

function _filesReflectWithFilter( test, o )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function makeOptions()
  {
    var o1 =
    {
      reflectMap :
      {
        [ '/srcExt' ] : '/dstExt'
      },
      src :
      {
        effectiveFileProvider : p.src,
        hasExtension : 'js',
      },
      dst :
      {
        effectiveFileProvider : p.dst,
        hasExtension : 'js',
      },
    };
    return o1;
  }

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    'a' : '/srcExt/a',
    'b.s' : '/srcExt/b.s',
    'c.js' : '/srcExt/c.js',
    srcEmptyDir :
    {
    },
    'srcEmptyDir.js' :
    {
    },
  }

  p.dst.filesTree.dst =
  {
    'a' : '/dstExt/a',
    'b.s' : '/dstExt/b.s',
    'c.js' : '/dstExt/c.js',
    dstEmptyDir :
    {
    },
    'dstEmptyDir.js' :
    {
    },
  }

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 0,
  }

  test.case = 'trivial \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'srcExt' :
      {
        'a' : '/srcExt/a',
        'b.s' : '/srcExt/b.s',
        'c.js' : '/srcExt/c.js',
        'srcEmptyDir' : {},
        'srcEmptyDir.js' : {},
      },

      'dstExt' :
      {
        'a' : '/dstExt/a',
        'b.s' : '/dstExt/b.s',
        'c.js' : '/srcExt/c.js',
        'dstEmptyDir' : {},
        'srcEmptyDir.js' : {},
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.srcExt );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dstExt );

  var expectedDstAbsolute = [ '/dst', '/dst/c.js', '/dst/srcEmptyDir.js', '/dst/dstEmptyDir.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/c.js', '/src/srcEmptyDir.js', '/src/dstEmptyDir.js' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true ];
  var expectedPreserve = [ true, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    d1a :
    {
      d1b :
      {
        'a' : '/srcExt/d1a/d1b/a',
        'b.s' : '/srcExt/d1a/d1b/b.s',
        'c.js' : '/srcExt/d1a/d1b/c.js',
      }
    },
  }

  p.dst.filesTree.dst =
  {
    d1a :
    {
      d1b :
      {
        'a' : '/dstExt/d1a/d1b/a',
        'b.js' : '/dstExt/d1a/d1b/b.js',
        'c.s' : '/dstExt/d1a/d1b/c.s',
      }
    },
    d2a :
    {
      d2b :
      {
        'a.js' : '/dstExt/d2a/d2b/a.js',
      }
    },
    d3a :
    {
      d3b :
      {
        'a.s' : '/dstExt/d3a/d3b/a.s',
      }
    },
    'd4a.js' :
    {
      'd4b.js' :
      {
        'a.s' : '/dstExt/d4a.js/d4b.js/a.s',
      }
    },
  }

  // '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js'

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 1,
  }

  test.case = 'trivial \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'src' :
      {
        d1a :
        {
          d1b :
          {
            'a' : '/srcExt/d1a/d1b/a',
            'b.s' : '/srcExt/d1a/d1b/b.s',
            'c.js' : '/srcExt/d1a/d1b/c.js',
          }
        },
      },

      'dst' :
      {
        d1a :
        {
          d1b :
          {
            'a' : '/dstExt/d1a/d1b/a',
            'c.s' : '/dstExt/d1a/d1b/c.s',
            'c.js' : '/srcExt/d1a/d1b/c.js',
          }
        },
        d3a :
        {
          d3b :
          {
            'a.s' : '/dstExt/d3a/d3b/a.s',
          }
        },
        'd4a.js' :
        {
          'd4b.js' :
          {
            'a.s' : '/dstExt/d4a.js/d4b.js/a.s',
          }
        },
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/d1a', '/dst/d1a/d1b', '/dst/d1a/d1b/c.js', '/dst/d1a/d1b/b.js', '/dst/d2a', '/dst/d2a/d2b', '/dst/d2a/d2b/a.js', '/dst/d3a', '/dst/d3a/d3b', '/dst/d4a.js', '/dst/d4a.js/d4b.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/d1a', '/src/d1a/d1b', '/src/d1a/d1b/c.js', '/src/d1a/d1b/b.js', '/src/d2a', '/src/d2a/d2b', '/src/d2a/d2b/a.js', '/src/d3a', '/src/d3a/d3b', '/src/d4a.js', '/src/d4a.js/d4b.js' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'ignore', 'ignore', 'ignore', 'ignore' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, false, false, false, false ];
  var expectedPreserve = [ true, true, true, false, false, false, false, false, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* - */

  var p = o.prepare();

  p.src.filesTree.src =
  {
    dSrcDirDstFile :
    {
      'a.js' :
      {
        'a' : '/srcExt/dSrcDirDstFile/a.js/a',
      }
    },
    dSrcFileDstDir :
    {
      'a.js' : '/srcExt/dSrcFileDstDir/a.js',
    },
    dSrcFileDstDir2 :
    {
      'a' : '/srcExt/dSrcFileDstDir2/a',
    },
  }

  p.dst.filesTree.dst =
  {
    dSrcDirDstFile :
    {
      'a.js' : '/dstExt/dSrcDirDstFile/a.js',
    },
    dSrcFileDstDir :
    {
      'a.js' :
      {
        'a.s' : '/dstExt/dSrcFileDstDir/a.js/a.s',
      }
    },
    dSrcFileDstDir2 :
    {
      'a' :
      {
        'a.js' : '/dstExt/dSrcFileDstDir2/a/a.js',
      }
    },
  }

  var o1 = makeOptions();
  o1.reflectMap = { [ '/src' ] : '/dst' }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
  }

  test.case = 'dir by term and vice-versa \n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      'src' :
      {
        dSrcDirDstFile :
        {
          'a.js' :
          {
            'a' : '/srcExt/dSrcDirDstFile/a.js/a',
          }
        },
        dSrcFileDstDir :
        {
          'a.js' : '/srcExt/dSrcFileDstDir/a.js'
        },
        dSrcFileDstDir2 :
        {
          'a' : '/srcExt/dSrcFileDstDir2/a'
        },
      },

      'dst' :
      {
        dSrcDirDstFile :
        {
          'a.js' : {}
        },
        dSrcFileDstDir :
        {
          'a.js' : '/srcExt/dSrcFileDstDir/a.js'
        },

      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dSrcDirDstFile', '/dst/dSrcDirDstFile/a.js', '/dst/dSrcFileDstDir', '/dst/dSrcFileDstDir/a.js', '/dst/dSrcFileDstDir/a.js/a.s', '/dst/dSrcFileDstDir2', '/dst/dSrcFileDstDir2/a', '/dst/dSrcFileDstDir2/a/a.js' ];
  var expectedSrcAbsolute = [ '/src', '/src/dSrcDirDstFile', '/src/dSrcDirDstFile/a.js', '/src/dSrcFileDstDir', '/src/dSrcFileDstDir/a.js', '/src/dSrcFileDstDir/a.js/a.s', '/src/dSrcFileDstDir2', '/src/dSrcFileDstDir2/a', '/src/dSrcFileDstDir2/a/a.js' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, true, false, true, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

}

//

function filesReflect( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function prepareSingle()
  {

    var tree = _.FileProvider.Extract
    ({
      filesTree :
      {
        dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst2 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst3 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
        src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
      },
    });

    return { src : tree, dst : tree, hub : tree };
  }

  function prepareTwo()
  {
    var dst = _.FileProvider.Extract
    ({
      filesTree :
      {
        dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst2 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
        dst3 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
      },
    });
    var src = _.FileProvider.Extract
    ({
      filesTree :
      {
        src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
        src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
        src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
      },
    });
    var hub = new _.FileProvider.Hub({ empty : 1 });
    src.originPath = 'extract+src://';
    dst.originPath = 'extract+dst://';
    hub.providerRegister( src );
    hub.providerRegister( dst );
    return { src : src, dst : dst, hub : hub };
  }

  /* */

  var o =
  {
    prepare : prepareSingle,
  }

  _filesReflect.call( context, test, o );

  /* */

  var o =
  {
    prepare : prepareTwo,
  }

  _filesReflect.call( context, test, o );

}

filesReflect.timeOut = 300000;

//

function _filesReflect( test, o )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function optionsMake()
  {
    var options =
    {
      reflectMap : { '/src' : '/dst' },
      src : { effectiveFileProvider : p.src },
      dst : { effectiveFileProvider : p.dst },
    }
    return options;
  }

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, true, false, false, false, false, false, false, false, true, false, true, false, false, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstRewriting', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/a1' ), p.dst.path.globalFromPreferred( '/dst/a1' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/a1' ), p.src.path.globalFromPreferred( '/src/a1' ) ]), false );
  test.identical( p.hub.filesAreHardLinked([ p.src.path.globalFromPreferred( '/src/a1' ), p.dst.path.globalFromPreferred( '/dst/a1' ) ]), false );
  test.identical( p.hub.filesAreHardLinked([ p.src.path.globalFromPreferred( '/src/a1' ), p.src.path.globalFromPreferred( '/src/a1' ) ]), true );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'softLink',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with linking : softLink\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : [{ softLink : p.src.path.globalFromPreferred( '/src/a1' ) }], b : [{ softLink : p.src.path.globalFromPreferred( '/src/b' ) }], c : [{ softLink : p.src.path.globalFromPreferred( '/src/c' ) }], dir : { a2 : '2', a1 : [{ softLink : p.src.path.globalFromPreferred( '/src/dir/a1' ) }], b : [{ softLink : p.src.path.globalFromPreferred( '/src/dir/b' ) }], c : [{ softLink : p.src.path.globalFromPreferred( '/src/dir/c' ) }] }, dirSame : { d : [{ softLink : p.src.path.globalFromPreferred( '/src/dirSame/d' ) }] }, dir1 : { a1 : [{ softLink : p.src.path.globalFromPreferred( '/src/dir1/a1' ) }], b : [{ softLink : p.src.path.globalFromPreferred( '/src/dir1/b' ) }], c : [{ softLink : p.src.path.globalFromPreferred( '/src/dir1/c' ) }] }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : [{ softLink : p.src.path.globalFromPreferred( '/src/srcFile' ) }], dstFile : { f : [{ softLink : p.src.path.globalFromPreferred( '/src/dstFile/f' ) }] } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'softLink', 'softLink', 'softLink', 'softLink', 'fileDelete', 'dirMake', 'softLink', 'softLink', 'softLink', 'dirMake', 'softLink', 'softLink', 'softLink', 'dirMake', 'dirMake', 'dirMake', 'softLink', 'dirMake', 'softLink' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/a1' ), p.dst.path.globalFromPreferred( '/dst/a1' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/a2' ), p.dst.path.globalFromPreferred( '/dst/a2' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/b' ), p.dst.path.globalFromPreferred( '/dst/b' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/dir/a1' ), p.dst.path.globalFromPreferred( '/dst/dir/a1' ) ]), true );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/dir/a2' ), p.dst.path.globalFromPreferred( '/dst/dir/a2' ) ]), false );
  test.identical( p.hub.filesAreSoftLinked([ p.src.path.globalFromPreferred( '/src/dir/b' ), p.dst.path.globalFromPreferred( '/dst/dir/b' ) ]), true );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 0,
    preservingTime : 0,
  }

  test.case = 'complex move with dstRewriting:0, includingNonAllowed:0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    includingNonAllowed : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with dstRewriting:0, includingNonAllowed:1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();

  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 0,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with writing : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();

  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with writing : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst :
      {
        a2 : '2',
        b : '1',
        c : '2',
        dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' },
        dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {},
        dir5 : {},
        dir1 : {},
        dir4 : {},
        dstFile : {},
      },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'fileDelete', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake', 'nop' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  test.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 0, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'nop', 'dirMake', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'nop',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 1,
  }

  test.case = 'complex move with writing : 1, dstRewriting : 0, includingNonAllowed : 1, linking : nop\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dir1 : {}, dir4 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'nop', 'nop', 'nop', 'nop', 'fileDelete', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'nop', 'nop', 'nop', 'dirMake', 'dirMake', 'dirMake', 'nop', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  // logger.log( 'expectedEffAbsolute', expectedEffAbsolute );
  logger.log( 'action', action );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    preservingSame : 1,
  }

  test.case = 'complex move with preservingSame : 1, linking : fileCopy\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, false, true, false, true, false, false, false, false, false, true, false, true, true, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with srcDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      dst : { a2 : '2', a1 : '1', b : '1', c : '1', dir : { a2 : '2', a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', null, 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with srcDeleting : 1, dstRewriting : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake' ];
  var expectedAllow = [ true, true, false, false, false, false, true, true, false, false, true, true, true, true, true, true, true, false, false ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', null, null, null, null, 'fileDelete', 'fileDelete', null, null, 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', null, null ];
  var expectedSrcAllow = [ false, true, true, true, true, true, false, true, true, true, true, true, true, true, true, true, false, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  test.case = 'complex move with srcDeleting : 1, dstRewriting : 0, includingNonAllowed : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst : { a2 : '2', a1 : '1', b : '1', c : '2', dir : { a2 : '2', a1 : '1', b : '1', c : '2' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir4 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true ];
  var expectedSrcActions = [ 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedSrcAllow = [ false, true, false, true, true, true, true, true, true, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var srcActions = _.select( records, '*/srcAction' );
  var srcAllow = _.select( records, '*/srcAllow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( srcActions, expectedSrcActions );
  test.identical( srcAllow, expectedSrcAllow );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'complex move with dstDeleting : 1\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
      dst : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst/srcFile', '/dst/srcFile/f', '/dst/dir', '/dst/dir/a1', '/dst/dir/b', '/dst/dir/c', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/dstFile/f', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/b', '/src/c', '/src/srcFile', '/src/srcFile/f', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/dirSame/d', '/src/dstFile', '/src/dstFile/f', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, true, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 1,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 0,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
    includingNonAllowed : 0,
  }

  test.case = 'complex move with dstDeleting : 1, dstRewriting : 0, srcDeleting : 1, includingNonAllowed : 0\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {
      src : { b : '1', c : '1', dir : { b : '1', c : '1' }, dirSame : { d : '1' }, srcFile : '1', dstFile : { f : '1' } },
      dst :
      {
        b : '1', c : '2', dirSame : { d : '1' }, dstFile : '1', srcFile : { f : '2' },
        dir : { b : '1', c : '2', a1 : '1' },
        dir3 : {},
        a1 : '1',
        dir1 : { a1 : '1', b : '1', c : '1' },
        dir4 : {},
      },
    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/dir', '/dst/dir/a1', '/dst/dir/a2', '/dst/dir1', '/dst/dir1/a1', '/dst/dir1/b', '/dst/dir1/c', '/dst/dir3', '/dst/dir4', '/dst/dirSame', '/dst/a2', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir5' ];
  var expectedSrcAbsolute = [ '/src', '/src/a1', '/src/dir', '/src/dir/a1', '/src/dir/a2', '/src/dir1', '/src/dir1/a1', '/src/dir1/b', '/src/dir1/c', '/src/dir3', '/src/dir4', '/src/dirSame', '/src/a2', '/src/dir2', '/src/dir2/a2', '/src/dir2/b', '/src/dir2/c', '/src/dir5' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'dirMake', 'dirMake', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, true, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir' : [ '/dst', '/dstNew' ],
    '/src/dirSame' : [ '/dst', '/dstNew' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d', '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, true, false, false, false, false, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**' : '/dstNew',
    '/src/dirSame/**' : '/dstNew',
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

      dstNew :
      {
        a1 : '1', b : '1', c : '1',
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/a1', '/dstNew/b', '/dstNew/c', '/dstNew', '/dstNew/d', '/dst', '/dst/a1', '/dst/b', '/dst/c', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/a1', '/src/dir/b', '/src/dir/c', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );

  /* */

  test.case = 'strange behavior fix';

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/*()dir/**b**' : '/dst',
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'base marker *()\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        dir : { a2 : '2', b : '1', c : '2' },
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/dir', '/dst/dir/b' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true ];
  var expectedPreserve = [ true, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

/*

var dst = _.FileProvider.Extract
({
  filesTree :
  {
    dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    dst2 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
    dst3 : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  },
});

var src = _.FileProvider.Extract
({
  filesTree :
  {
    src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
    src2 : { ax2 : '10', bx : '10', cx : '10', dirx : { a : '10' } },
    src3 : { ax2 : '20', by : '20', cy : '20', dirx : { a : '20' } },
  },
});

*/

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : '/dst',
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        // a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        // dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        // dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        // /**/
        b : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );

  var expectedDstAbsolute = [ '/dst', '/dst/b', '/dst/a2', '/dst/c', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dir/a2', '/src/dir/c', '/src/dir/dir', '/src/dir/dir/a2', '/src/dir/dir/b', '/src/dir/dir/c', '/src/dir/dir2', '/src/dir/dir2/a2', '/src/dir/dir2/b', '/src/dir/dir2/c', '/src/dir/dir3', '/src/dir/dir5', '/src/dir/dirSame', '/src/dir/dirSame/d', '/src/dir/dstFile', '/src/dir/srcFile', '/src/dir/srcFile/f' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        // a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        // dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        // dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        // /**/
        b : '1',
        d : '1',
      },

      dstNew :
      {
        b : '1',
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst/a2', '/dst/c', '/dst/dir', '/dst/dir/a2', '/dst/dir/b', '/dst/dir/c', '/dst/dir2', '/dst/dir2/a2', '/dst/dir2/b', '/dst/dir2/c', '/dst/dir3', '/dst/dir5', '/dst/dirSame', '/dst/dirSame/d', '/dst/dstFile', '/dst/srcFile', '/dst/srcFile/f', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dir/a2', '/src/dir/c', '/src/dir/dir', '/src/dir/dir/a2', '/src/dir/dir/b', '/src/dir/dir/c', '/src/dir/dir2', '/src/dir/dir2/a2', '/src/dir/dir2/b', '/src/dir/dir2/c', '/src/dir/dir3', '/src/dir/dir5', '/src/dir/dirSame', '/src/dir/dirSame/d', '/src/dir/dstFile', '/src/dir/srcFile', '/src/dir/srcFile/f', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'fileDelete', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false ];
  var expectedReason = [ 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'srcLooking', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'dstDeleting', 'srcLooking', 'srcLooking' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );
  var reason = _.select( records, '*/reason' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );
  test.identical( reason, expectedReason );

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/dir/**b**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'several srcs, dsts\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        b : '1',
        d : '1',
      },

      dstNew :
      {
        b : '1',
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/b', '/dstNew', '/dstNew/d', '/dst', '/dst/b', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, true, false, true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

/*
dst : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },
*/

  /* */

  var p = o.prepare();
  var o1 = optionsMake();
  o1.reflectMap =
  {
    '/src/*()dir/**b**' : [ '/dstNew', '/dst' ],
    '/src/dirSame/**d**' : [ '/dstNew', '/dst' ],
  }

  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 0,
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    preservingTime : 0,
  }

  test.case = 'base marker *()\n' + _.toStr( o2 );

  var records = p.hub.filesReflect( _.mapExtend( null, o1, o2 ) );

  var expected = _.FileProvider.Extract
  ({
    filesTree :
    {

      src : { a1 : '1', b : '1', c : '1', dir : { a1 : '1', b : '1', c : '1' }, dirSame : { d : '1' }, dir1 : { a1 : '1', b : '1', c : '1' }, dir3 : {}, dir4 : {}, srcFile : '1', dstFile : { f : '1' } },

      dst :
      {
        a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' },
        dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' },
        dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' },
        /**/
        dir : { a2 : '2', b : '1', c : '2' },
        d : '1',
      },

      dstNew :
      {
        dir : { b : '1' },
        d : '1',
      },

    },
  });

  test.identical( p.src.filesTree.src, expected.filesTree.src );
  test.identical( p.dst.filesTree.dst, expected.filesTree.dst );
  test.identical( p.dst.filesTree.dstNew, expected.filesTree.dstNew );

  var expectedDstAbsolute = [ '/dstNew', '/dstNew/dir', '/dstNew/dir/b', '/dstNew', '/dstNew/d', '/dst', '/dst/dir', '/dst/dir/b', '/dst', '/dst/d' ];
  var expectedSrcAbsolute = [ '/src', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d', '/src', '/src/dir', '/src/dir/b', '/src/dirSame', '/src/dirSame/d' ];

  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy', 'dirMake', 'dirMake', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, true, false, true, true, false, true, false ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

} /* eof _filesReflect */

//

function filesReflectOverlap( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* */

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        a : 'dir/a',
        b : 'dir/b',
        c :
        {
          a : 'dir/c/a'
        }
      }
    },
  });

  test.case = 'setup';
  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );

  var o1 =
  {
    src : abs( './dir' ),
    dst : abs( './dir/dst' ),
  }

  var records = provider.filesReflect( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedSrcRelative = [ '.', './a', './b', './c', './c/a' ];
  var expectedAction = [ 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var expectedTree =
  {
    'dir' :
    {
      'a' : 'dir/a',
      'b' : 'dir/b',
      'c' : { 'a' : 'dir/c/a' },
      'dst' :
      {
        'a' : 'dir/a',
        'b' : 'dir/b',
        'c' : { 'a' : 'dir/c/a' },
      }
    }
  }
  var extract2 = provider.filesExtract( routinePath );
  extract2.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    extract2.fileWrite( r.absolute, extract2.fileRead( r.absolute ) );
  }})
  test.identical( extract2.filesTree, expectedTree );

  /* */

  test.case = 'some sources does not exist';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      'dir' :
      {
        'proto' :
        {
          'File.js' : '/dir/proto/File.js',
          'File.s' : '/dir/proto/File.s',
        }
      }
    }
  });

  provider.filesDelete( routinePath );
  extract1.filesReflectTo( provider, routinePath );

  var o1 =
  {
    src :
    {
      filePath :
      {
        [abs( './dir/proto/File.js' )] : abs( './dir/out2' ),
        [abs( './dir/proto/File.s' )] : abs( './dir/out2' ),
      },
      basePath : abs( './dir/proto' ),
    }
  }

  var records = provider.filesReflect( _.mapExtend( null, o1 ) );

  var expectedDstRelative = [ './File.js', './File.s' ];
  var expectedSrcRelative = [ './File.js', './File.s' ];
  var expectedAction = [ 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true ];
  var expectedPreserve = [ false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  var o1 =
  {
    src :
    {
      filePath :
      {
        [abs( './dir/src1' )] : abs( './dir/dst1' ),
        [abs( './dir/proto/File.js' )] : abs( './dir/out2' ),
        [abs( './dir/proto/File.s' )] : abs( './dir/out2' ),
      },
      basePath : abs( './dir/proto' ),
    }
  }

  test.shouldThrowErrorSync( () => provider.filesReflect( _.mapExtend( null, o1 ) ) );

/*
"#foreground : blue#module::reflect-inherit / reflector::reflect.files1#foreground : default#
  src :
    filePath :
      /dir/src1 : /dir/dst1
      /dir/proto/File.js : /dir/out2
      /dir/proto/File.s : /dir/out2
    basePath : /dir/proto
  mandatory : 1
  inherit :
    reflector::files3"
*/

}

//

function filesReflectGrab( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'nothing to grab + prefix';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    '/dir**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
    mandatory : 0,
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [];
  var expectedSrcRelative = [];
  var expectedEffRelative = [];
  var expectedAction = [];
  var expectedAllow = [];
  var expectedPreserve = [];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'nothing to grab + dst';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    '/dir**' : routinePath,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src },
    dst : { hubFileProvider : provider },
    mandatory : 0,
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [];
  var expectedSrcRelative = [];
  var expectedEffRelative = [];
  var expectedAction = [];
  var expectedAllow = [];
  var expectedPreserve = [];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + src.basePath, dst null';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : null,
    './src2/d/**' : null,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });

  var found = provider.filesFindRecursive( routinePath );

  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  test.case = 'trivial + src.basePath, dst true';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  debugger;
  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  debugger;

  var found = provider.filesFindRecursive( routinePath );

  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + not defined src.basePath, did not exist';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, prefixPath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, true, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + not defined src.basePath, did exist';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
  }

  provider.dirMake( routinePath );
  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, prefixPath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/b', './d/c', '.', './a', './b', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ true, false, false, false, false, true, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'trivial + URIs';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    'extract+src:///src1/d**' : true,
    'extract+src:///src2/d/**' : true,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { basePath : '/' },
    dst : { prefixPath : 'current://' + routinePath },
  });
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/b', './src1/d/c', './src2/d', './src2/d/a', './src2/d/b', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + src basePath';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + prefixPath + basePath';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : true,
    './src2/d/**' : true,
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, prefixPath : '/', basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + base path only';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });

  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + src base path + dst base path';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath, basePath : routinePath },
  });
  src.finit();
  provider.filesDelete( routinePath );

  var expectedDstRelative = [ './src1x/src1', './src1x/src1/d', './src1x/src1/d/a', './src1x/src1/d/c', './src2x/src2/d', './src2x/src2/d/a', './src2x/src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + src base path - dst base path';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    './src1/d**' : './src1x/',
    './src2/d/**' : './src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
    src : { hubFileProvider : src, basePath : '/' },
    dst : { hubFileProvider : provider, prefixPath : routinePath },
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedFound = [ '.', './src1x', './src1x/src1', './src1x/src1/d', './src1x/src1/d/a', './src1x/src1/d/c', './src2x', './src2x/src2', './src2x/src2/d', './src2x/src2/d/a', './src2x/src2/d/c' ];
  var expectedDstRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedSrcRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedEffRelative = [ './src1', './src1/d', './src1/d/a', './src1/d/c', './src2/d', './src2/d/a', './src2/d/c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var found = _.select( found, '*/relative' );
  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( found, expectedFound );
  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

  /* */

  test.case = 'negative + dst + uri';

  var src = context.makeStandardExtract();
  src.originPath = 'extract+src://';
  src.providerRegisterTo( hub );

  var recipe =
  {
    'extract+src:///src1/d**' : 'current://' + routinePath + '/src1x/',
    'extract+src:///src2/d/**' : 'current://' + routinePath + '/src2x/',
    '**/b' : false,
  }

  var records = hub.filesReflect
  ({
    reflectMap : recipe,
  });
  var found = provider.filesFindRecursive( routinePath );
  src.finit();
  provider.filesDelete( routinePath );

  var expectedFound = [ '.', './src1x', './src1x/d', './src1x/d/a', './src1x/d/c', './src2x', './src2x/a', './src2x/c' ]
  var expectedDstRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedSrcRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedEffRelative = [ '.', './d', './d/a', './d/c', '.', './a', './c' ];
  var expectedAction = [ 'dirMake', 'dirMake', 'fileCopy', 'fileCopy', 'dirMake', 'fileCopy', 'fileCopy' ];
  var expectedAllow = [ true, true, true, true, true, true, true ];
  var expectedPreserve = [ false, false, false, false, false, false, false ];

  var found = _.select( found, '*/relative' );
  var dstRelative = _.select( records, '*/dst/relative' );
  var srcRelative = _.select( records, '*/src/relative' );
  var effRelative = _.select( records, '*/effective/relative' );
  var action = _.select( records, '*/action' );
  var allow = _.select( records, '*/allow' );
  var preserve = _.select( records, '*/preserve' );

  test.identical( found, expectedFound );
  test.identical( dstRelative, expectedDstRelative );
  test.identical( srcRelative, expectedSrcRelative );
  test.identical( effRelative, expectedEffRelative );
  test.identical( action, expectedAction );
  test.identical( allow, expectedAllow );
  test.identical( preserve, expectedPreserve );

}

//

function filesReflectorBasic( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dst = provider;

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  /* */

  test.description = 'setup';

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { hubFileProvider : src },
    dst : { hubFileProvider : dst, prefixPath : routinePath },
  });

  test.case = 'negative + dst + src base path';

  var recipe =
  {
    '/src1/d**' : routinePath + '/src1x/',
    '/src2/d/**' : routinePath + '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
  });

  var expectedDstAbsolute = abs([ 'src1x', 'src1x/d', 'src1x/d/a', 'src1x/d/c', 'src2x', 'src2x/a', 'src2x/c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'negative + dst';

  var recipe =
  {
    '/src1/d**' : routinePath + '/src1x/',
    '/src2/d/**' : routinePath + '/src2x/',
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    src : { basePath : null },
  });

  var expectedDstAbsolute = abs([ 'src1x', 'src1x/d', 'src1x/d/a', 'src1x/d/c', 'src2x', 'src2x/a', 'src2x/c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  test.case = 'negative';

  var recipe =
  {
    '/src1/d**' : true,
    '/src2/d/**' : true,
    '**/b' : false,
  }

  var records = reflect
  ({
    reflectMap : recipe,
    src : { basePath : null },
  });

  var expectedDstAbsolute = abs([ '.', 'd', 'd/a', 'd/c', '', 'a', 'c' ]);
  var expectedSrcAbsolute =  [ '/src1', '/src1/d', '/src1/d/a', '/src1/d/c', '/src2/d', '/src2/d/a', '/src2/d/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  test.open( 'reflect current dir' );

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : {},
    dst : {},
  });
  test.shouldThrowError( () => reflect( '/' ) );
  var found = dst.filesFind({ filePath : routinePath, allowingMissed : 1 });
  test.identical( found.length, 0 );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  if( Config.debug )
  {

    var src = context.makeStandardExtract({ originPath : 'src://' });
    src.providerRegisterTo( hub );

    var reflect = hub.filesReflector
    ({
      src : { basePath : 'src:///' },
      dst : { basePath : 'current:///' },
    });
    test.shouldThrowErrorSync( () => reflect( '/' ) );

    dst.filesDelete( routinePath );
    src.finit();

  }

  /* */

  if( Config.debug )
  {

    var src = context.makeStandardExtract({ originPath : 'src://' });
    src.providerRegisterTo( hub );

    var reflect = hub.filesReflector
    ({
      src : { basePath : 'src:///' },
      dst : { basePath : 'current:///' },
    });
    test.shouldThrowError( () => reflect( '/' ) );

    dst.filesDelete( routinePath );
    src.finit();

  }

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath },
  });
  test.mustNotThrowError( () => reflect( '/' ) );
  var extract = provider.filesExtract( routinePath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, src.filesTree );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath, basePath : 'current://' + routinePath },
  });
  reflect( '/alt/a' );
  var extract = provider.filesExtract( routinePath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath, basePath : 'current://' + routinePath },
    mandatory : 0,
  });
  reflect( '/alt/alt' );
  var extract = provider.filesExtract( routinePath );
  test.identical( extract.filesTree, {} );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///a/b' },
    dst : { prefixPath : 'current://' + routinePath + '/1/2', basePath : 'current://' + routinePath + '/1/2' },
  });
  reflect( 'alt' );
  var expected =
  {
    alt :
    {
      a : '/alt/a',
      d : { a : '/alt/d/a' }
    }
  }
  var extract = provider.filesExtract( routinePath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, expected );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath, basePath : 'current://' + routinePath + '/a/b' },
  });
  reflect( '/alt/a' )
  var extract = provider.filesExtract( routinePath );
  if( provider instanceof _.FileProvider.HardDrive )
  {
    var files = extract.filesFindRecursive({ filePath : '/', includingTerminals : 1, includingDirs : 0, includingStem : 0 })
    _.each( files, ( f ) => extract.fileWrite( f.absolute, extract.fileRead( f.absolute ) ) )
  }
  test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath, basePath : 'current://' + routinePath },
    linking : 'fileCopy',
    mandatory : 1,
  });

  reflect( '/alt/a' );

  var extract = provider.filesExtract( routinePath );
  extract.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    extract.fileWrite( r.absolute, extract.fileRead( r.absolute ) );
  }})
  test.identical( extract.filesTree, { alt : { a : '/alt/a' } } );
  test.identical( provider.statRead( routinePath + '/alt/a' ).isTerminal(), true );

  dst.filesDelete( routinePath );
  src.finit();

  /* */

  var src = context.makeStandardExtract({ originPath : 'src://' });
  src.providerRegisterTo( hub );

  var reflect = hub.filesReflector
  ({
    src : { prefixPath : 'src:///', basePath : 'src:///' },
    dst : { prefixPath : 'current://' + routinePath, basePath : 'current://' + routinePath },
    linking : 'softLink',
    mandatory : 1,
  });

  reflect( '/alt/a' );

  if( provider instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () => provider.fileRead( abs( './alt/a' ) ))
  }
  else
  {
    var extract = provider.filesExtract( routinePath );
    test.identical( extract.filesTree, { alt : { a : [{ softLink : 'src:///alt/a' }] } } );
    test.identical( provider.statRead( routinePath + '/alt/a' ).isSoftLink(), true );
  }

  dst.filesDelete( routinePath );
  src.finit();

  test.close( 'reflect current dir' );

} /* end of filesReflectorBasic */

//

function filesReflectWithHub( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dstProvider = provider;
  let dstPath = routinePath;

  var filesTree =
  {
    src : { a2 : '2', b : '1', c : '2', dir : { a2 : '2', b : '1', c : '2' }, dirSame : { d : '1' }, dir2 : { a2 : '2', b : '1', c : '2' }, dir3 : {}, dir5 : {}, dstFile : '1', srcFile : { f : '2' } },
  }

  var srcProvider = _.FileProvider.Extract({ filesTree : filesTree, protocols : [ 'extract' ] });
  srcProvider.providerRegisterTo( hub );
  // var dstProvider = new _.FileProvider.HardDrive();
  var srcPath = '/src';

  // var dstPath = path.join( context.testSuitePath, test.name, 'dst' );
  // var hub = new _.FileProvider.Hub({ empty : 1 });
  // hub.providerRegister( srcProvider );
  // hub.providerRegister( dstProvider );

  /* */

  test.case = 'from Extract to HardDrive, using local absolute paths'
  dstProvider.filesDelete( dstPath );
  var o1 =
  {
    reflectMap : { [ srcPath ] : dstPath },
    src : { effectiveFileProvider : srcProvider },
    dst : { effectiveFileProvider : dstProvider },
  };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  test.is( records.length >= 0 );

  var extract2 = dstProvider.filesExtract( dstPath );
  extract2.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    extract2.fileWrite( r.absolute, extract2.fileRead( r.absolute ) );
  }})
  test.identical( extract2.filesTree, /*context.select*/_.select( filesTree, srcPath ) )

  /* */

  test.case = 'files from Extract to HardDrive, using global uris'
  dstProvider.filesDelete( dstPath );
  var srcUrl = srcProvider.path.globalFromPreferred( srcPath );
  var dstUrl = dstProvider.path.globalFromPreferred( dstPath );
  var o1 = { reflectMap : { [ srcUrl ] : dstUrl } };
  var o2 =
  {
    linking : 'fileCopy',
    srcDeleting : 0,
    dstDeleting : 1,
    writing : 1,
    dstRewriting : 1
  }

  var records = hub.filesReflect( _.mapExtend( null, o1, o2 ) );
  test.is( records.length >= 0 );

  var extract2 = dstProvider.filesExtract( dstPath );
  extract2.filesFind({ filePath : '/', recursive : 2, onDown : function onDown( r, o )
  {
    if( r.isTerminal )
    extract2.fileWrite( r.absolute, extract2.fileRead( r.absolute ) );
  }})
  test.identical( extract2.filesTree, /*context.select*/_.select( filesTree, '/src' ) );

  dstProvider.filesDelete( dstPath );
  srcProvider.finit();
}

//

function filesReflectLinkWithHub( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let dstPath = routinePath;
  let dst = provider;

  var filesTree =
  {
    'terminal' : 'terminal',
    'link' : [{ softLink : '/terminal' }]
  }
  var src = new _.FileProvider.Extract({ protocol : 'src', filesTree : filesTree });

  src.providerRegisterTo( hub );

  /* */

  test.case = 'resolvingSrcSoftLink : default, with prefixPath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : 2, with prefixPath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 2,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : default, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : 2, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 2,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : 1, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 1,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : 2, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 2,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  test.case = 'resolvingSrcSoftLink : 0, with filePath';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  hub.filesReflect
  ({
    dst :
    {
      filePath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      filePath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 0,
  });

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : default, with reflector';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  var reflect = hub.filesReflector
  ({
    dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : null,
  });

  reflect( '.' );

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( !dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  if( dst instanceof _.FileProvider.HardDrive )
  {
    test.shouldThrowErrorSync( () =>
    {
      dst.fileRead( _.path.join( dstPath, 'link' ) )
    })
  }
  else
  {
    var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
    var expected = 'terminal';
    test.identical( got, expected );
  }

  /* */

  test.case = 'resolvingSrcSoftLink : 2, with reflector';

  dst.filesDelete( dstPath );
  hub.filesReflect({ reflectMap : { [ 'src:///' ] : 'current://' + dstPath } });

  var reflect = hub.filesReflector
  ({
    dst :
    {
      prefixPath : _.uri.join( 'current://', dstPath ),
    },
    src :
    {
      prefixPath : _.uri.join( 'src://', '/' ),
    },
    mandatory : 1,
    resolvingSrcSoftLink : 2,
  });

  reflect( '.' );

  var got = dst.dirRead( dstPath );
  var expected = [ 'link', 'terminal' ];
  test.identical( got, expected );
  test.is( dst.isTerminal( _.path.join( dstPath, 'terminal' ) ) );
  test.is( dst.isTerminal( _.path.join( dstPath, 'link' ) ) );
  test.is( !dst.isSoftLink( _.path.join( dstPath, 'link' ) ) );
  var got = dst.fileRead( _.path.join( dstPath, 'link' ) );
  var expected = 'terminal';
  test.identical( got, expected );

  /* */

  src.finit();
  dst.filesDelete( routinePath );

}

//

function filesReflectDeducing( test )
{
  var c = this;

  /* */

  test.case = 'both prefixes defined, relative dst and src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap :
    {
      '.' : '.',
    },
    src :
    {
      prefixPath : '/src/srcDir',
    },
    dst :
    {
      prefixPath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'both prefixes defined, relative dst';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap :
    {
      '/src/srcDir' : '.',
    },
    src :
    {
      prefixPath : '/src/srcDir2',
    },
    dst :
    {
      prefixPath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, single path';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    src :
    {
      filePath : '/src/srcDir',
    },
    dst :
    {
      filePath : '/dst/dstDir2',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, single path';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    src :
    {
      prefixPath : '/src',
      filePath : { 'srcDir' : 'dstDir2' },
    },
    dst :
    {
      prefixPath : '/dst',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, dstDir2 : { a : 'src/a', b : 'src/b' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, multiple paths';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    src :
    {
      filePath : [ '/src/srcDir', '/src/srcDir2' ],
    },
    dst :
    {
      filePath : [ '/dst/dstDir', '/dst/dstDir2' ]
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'src/a', b : 'src/b', c : 'dst/c', e : 'src/e' }, dstDir2 : { a : 'src/a', b : 'src/b', e : 'src/e' } },
  }
  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/b', '/dst/dstDir', '/dst/dstDir/e', '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b', '/dst/dstDir2', '/dst/dstDir2/e' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];


  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );


  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );


  /* */

  test.case = 'no reflect map, multiple paths, hub';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' } },
  }

  var o =
  {
    reflectMap : null,
    src :
    {
      filePath : [ 'extract:///src/srcDir', 'extract:///src/srcDir2' ],
    },
    dst :
    {
      filePath : [ 'extract:///dst/dstDir', 'extract:///dst/dstDir2' ]
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var hub = new _.FileProvider.Hub({ providers : [ provider ] });
  var records = hub.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d',  },
    dst : { dstDir : { a : 'src/a', b : 'src/b', c : 'dst/c', e : 'src/e' }, dstDir2 : { a : 'src/a', b : 'src/b', e : 'src/e' } },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/b', '/dst/dstDir', '/dst/dstDir/e', '/dst/dstDir2', '/dst/dstDir2/a', '/dst/dstDir2/b', '/dst/dstDir2', '/dst/dstDir2/e' ];
  var expectedSrcAbsolute = [ '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'no reflect map, multiple paths, hub';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { '.' : true },
      basePath : { '.' : '.' },
    },
    dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/srcDir', '/dst/srcDir/a', '/dst/srcDir/b', '/dst/srcDir2', '/dst/srcDir2/e' ];
  var expectedSrcAbsolute = [ '/src', '/src/c', '/src/d', '/src/srcDir', '/src/srcDir/a', '/src/srcDir/b', '/src/srcDir2', '/src/srcDir2/e' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, no src base';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'd' : true },
    },
    dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/d', '/src/d/c', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, src base';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      basePath : '.',
      filePath : { 'd' : true },
    },
    dst :
    {
      prefixPath : '/dst',
      basePath : { '.' : '.' },
      filePath : '.',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'src/d' },
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/d' ];
  var expectedSrcAbsolute = [ '/src/d' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, single src, no src base, no dst base, no dst';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'd' : true },
    },
    dst :
    {
      prefixPath : '/dst',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst', '/dst/c', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/d', '/src/d/c', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, multiple src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'c' : 'c2', 'd' : null },
    },
    dst :
    {
      prefixPath : '/dst',
      filePath : '.',
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = provider.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( provider.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/c2', '/dst', '/dst/c', '/dst/c2', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/c', '/src/d', '/src/d/c', '/src/d/c2', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  /* */

  test.case = 'mixed file path, multiple src';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'srcDir2' : null, 'c' : 'c2', 'd' : null },
    },
    dst :
    {
      prefixPath : '/dst',
      filePath : '.',
      basePath : { '.' : '.' },
    },
  }

  var provider = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  test.shouldThrowErrorSync( () =>
  {
    var records = provider.filesReflect( o );
  });

}

//

function filesReflectDstPreserving( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var filesTree =
  {
    src :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-test' : { 'file' : 'file', 'dir-test' : { 'file' : 'file' } },
      'dir-test-inner' : { 'dir-test' : { 'file' : 'file' } },
      'dir-d' : { 'file-d' : 'file-diff-content' },
      'dir-s' : { 'file' : 'file' },
    },
    dst :
    {
      'file' : 'file',
      'file-d' : 'file-diff-content',
      'dir-e' : { 'dir-e' : {} },
      'dir-test' : { 'file' : 'file', 'dir-test' : { 'file' : 'file' } },
      'dir-test-inner' : { 'dir-test' : { 'file' : 'file' } },
      'dir-d' : { 'file-d' : 'file-content-diff' },
      'dir-s' : { 'file' : 'file' },
    }
  }

  /* */

  test.case = 'terminal - terminal, same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - terminal, same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - terminal, diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file-d' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file-d' );
  var dst = extract.fileRead( '/dst/file' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file-d' ) );

  test.case = 'terminal - terminal, diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file-d' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file-d' );
  var dst = extract.fileRead( '/dst/file' );
  test.notIdentical( src, dst );

  /* */

  test.case = 'terminal - empty dir, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e/dir-e' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir without terminals, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - empty dir, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e/dir-e' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir without terminals, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-e' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-e' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-test' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var src = extract.fileRead( '/src/file' );
  var dst = extract.fileRead( '/dst/dir-test-inner' );
  test.identical( src, dst );
  test.identical( src, /*context.select*/_.select( filesTree, '/src/file' ) );

  test.case = 'terminal - dir with terminals, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-test' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file' ), /*context.select*/_.select( filesTree, '/src/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/dir-test' ), /*context.select*/_.select( filesTree, '/dst/dir-test' ) );

  test.case = 'terminal - dir with terminals inner level, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/file' : '/dst/dir-test-inner' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/file' ) );
  test.is( extract.isDir( '/dst/dir-test-inner' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file' ), /*context.select*/_.select( filesTree, '/src/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/dir-test-inner' ), /*context.select*/_.select( filesTree, '/dst/dir-test-inner' ) );

  /* */

  test.case = 'dir empty - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e/dir-e' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e/dir-e' ), /*context.select*/_.select( filesTree, '/src/dir-e/dir-e' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e/dir-e' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  test.case = 'dir empty - terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e/dir-e' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e/dir-e' ), /*context.select*/_.select( filesTree, '/src/dir-e/dir-e' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/file' ), /*context.select*/_.select( filesTree, '/dst/file' ) );

  test.case = 'dir without terminal - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e' ), /*context.select*/_.select( filesTree, '/src/dir-e' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  test.case = 'dir without terminal - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-e' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-e' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-e' ), /*context.select*/_.select( filesTree, '/src/dir-e' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/file' ), /*context.select*/_.select( filesTree, '/dst/file' ) );

  test.case = 'dir with files - terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-test' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-test' ) );
  test.is( extract.isDir( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-test' ), /*context.select*/_.select( filesTree, '/src/dir-test' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/file' ), /*context.select*/_.select( extract.filesTree, '/src/dir-test' ) );

  test.case = 'dir with files - terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-test' : '/dst/file' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isDir( '/src/dir-test' ) );
  test.is( extract.isTerminal( '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-test' ), /*context.select*/_.select( filesTree, '/src/dir-test' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/file' ), /*context.select*/_.select( filesTree, '/dst/file' ) );

  /**/

  test.case = 'reflect dir - dir, both with same terminal, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-s' : '/dst/dir-s' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-s' ), /*context.select*/_.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both with same terminal, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-s' : '/dst/dir-s' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-s' ), /*context.select*/_.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both have terminal with diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-d' : '/dst/dir-d' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-s' ), /*context.select*/_.select( extract.filesTree, '/dst/dir-s' ) );

  test.case = 'reflect dir - dir, both have terminal with diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap : { '/src/dir-d' : '/dst/dir-d' },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/src/dir-s/file' ) );
  test.is( extract.isTerminal( '/dst/dir-s/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/dir-d/file-d' ), /*context.select*/_.select( filesTree, '/src/dir-d/file-d' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/dst/dir-d/file-d' ), /*context.select*/_.select( filesTree, '/dst/dir-d/file-d' ) );

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file1',
      file2 : 'file2',
    },
    dst :
    {
    }
  }

  test.case = 'reflect two terminals to same dst path, src termianls have different content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect two terminals to same dst path, src termianls have different content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );
  test.is( !extract.fileExists( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file1' ), 'file1' );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), 'file2' );
  test.is( !/*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file',
      file2 : 'file',
      file3 : 'file3',
    },
    dst :
    {
    }
  }

  test.case = 'reflect two terminals to same dst path, src termianls have same content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file1' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect two terminals to same dst path, src termianls have same content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file1' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls has diff content, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.notIdentical( /*context.select*/_.select( extract.filesTree, '/src/file1' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file3' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls has diff content, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );
  test.is( !extract.fileExists( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file1' ), 'file' );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file2' ), 'file' );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file3' ), 'file3' );

  /*  */

  var filesTree =
  {
    src :
    {
      file1 : 'file',
      file2 : [{ softLink : '/src/file4' }],
      file3 : 'file',
      file4 : 'file3',
    },
    dst :
    {
    }

  }

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls is a softLink, dstRewritingPreserving : 0';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 0
  }

  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file3' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( /*context.select*/_.select( extract.filesTree, '/src/file4' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  //

  test.case = 'reflect three terminals to same dst path, one of src termianls is a softLink, dstRewritingPreserving : 1';
  var extract = _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree )  });
  var o =
  {
    reflectMap :
    {
      '/src/file1' : '/dst/file',
      '/src/file2' : '/dst/file',
      '/src/file3' : '/dst/file'
    },
    writing : 1,
    dstRewriting : 1,
    dstRewritingByDistinct : 1,
    dstRewritingPreserving : 1
  }

  test.mustNotThrowError( () => extract.filesReflect( o ) );
  test.is( extract.isTerminal( '/dst/file' )  );
  test.identical( /*context.select*/_.select( extract.filesTree, '/src/file3' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );
  test.notIdentical( /*context.select*/_.select( extract.filesTree, '/src/file4' ), /*context.select*/_.select( extract.filesTree, '/dst/file' ) );

  /*  */

  test.case = 'mixed file path, multiple src, dstRewritingPreserving : 0';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'c' : '/dst/c2', 'd' : '/dst' },
    },
    dstRewritingPreserving : 0
  }

  var extract = new _.FileProvider.Extract({ filesTree : tree, protocol : 'extract' });
  var records = extract.filesReflect( o );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : 'src/d',
  }

  test.identical( extract.filesTree, expectedTree );

  var expectedDstAbsolute = [ '/dst/c2', '/dst', '/dst/c', '/dst/c2', '/dst/d', '/dst/dstDir', '/dst/dstDir/a', '/dst/dstDir/c' ];
  var expectedSrcAbsolute = [ '/src/c', '/src/d', '/src/d/c', '/src/d/c2', '/src/d/d', '/src/d/dstDir', '/src/d/dstDir/a', '/src/d/dstDir/c' ];

  var dstAbsolute = _.select( records, '*/dst/absolute' );
  var srcAbsolute = _.select( records, '*/src/absolute' );

  test.identical( dstAbsolute, expectedDstAbsolute );
  test.identical( srcAbsolute, expectedSrcAbsolute );

  //

  test.case = 'mixed file path, multiple src, dstRewritingPreserving : 1';

  var tree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', d : 'dst/d' },
  }

  var o =
  {
    src :
    {
      prefixPath : '/src',
      filePath : { 'c' : '/dst/c2', 'd' : '/dst' },
    },
    dstRewritingPreserving : 1
  }

  var extract = new _.FileProvider.Extract({ filesTree : _.cloneJust( tree ), protocol : 'extract' });
  test.shouldThrowErrorSync( () => extract.filesReflect( o ) );

  var expectedTree =
  {
    src : { srcDir : { a : 'src/a', b : 'src/b' }, srcDir2 : { e : 'src/e' }, c : 'src/c', d : 'src/d' },
    dst : { dstDir : { a : 'dst/a', c : 'dst/c' }, c : 'dst/c', c2 : 'src/c', d : 'dst/d' },
  }

  test.identical( extract.filesTree, expectedTree );
}

//

function filesReflectDstDeletingDirs( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'dst/dir is actual, will be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is actual, will be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is excluded, will not be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir is excluded, will not be deleted';
  var filesTree =
  {
    src : {},
    dst : { dir : {} }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, not actual, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, actual, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : [ 'file', 'dir' ] } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, not actual, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'dst/dir cleaned, actual, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : [ 'file', 'dir' ] } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
   test.identical( extract.filesTree, expected );

  //

  test.case = 'file included, parent dir excluded, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'file included, parent dir excluded, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : 'file', excludeAny : 'dir' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file : 'file' } }
  }
  test.identical( extract.filesTree, expected );

  //

  test.case = 'cleaned dir have files, dstDeletingCleanedDirs : 1 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : 'file1' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'cleaned dir have files, dstDeletingCleanedDirs : 0 ';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : 'file1' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : { file2 : 'file2' } }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : {}
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : {},
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : {},
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : { dir : {} },
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
    dst : { maskAll : { includeAny : 'file' } }
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    src : { dir : {} },
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, srcDeleting : 1, dstDeletingCleanedDirs : 1';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcDeleting : 1,
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 1,
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );

  test.case = 'dir cleaned, same dir exists on src, srcDeleting : 1, dstDeletingCleanedDirs : 0';
  var filesTree =
  {
    src : { dir : {} },
    dst : { dir : { file1 : 'file1', file2 : 'file2' } }
  }
  var extract = _.FileProvider.Extract({ filesTree : filesTree });
  var o =
  {
    reflectMap : { '/src' : '/dst' },
    srcDeleting : 1,
    writing : 1,
    dstDeleting : 1,
    dstDeletingCleanedDirs : 0,
  }
  test.mustNotThrowError( () => extract.filesReflect( o ) );
  var expected =
  {
    dst : { dir : {} }
  }
  test.identical( extract.filesTree, expected );
}

//qqq:extend filesReflectLinked with new cases for resolvingSrcSoftLink: 0-2

function filesReflectLinked( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;

  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  var srcPath = path.join( routinePath, 'src' );
  var dstPath = path.join( routinePath, 'dst' );
  var dstLinkPath = path.join( dstPath, 'link' );
  var srcLinkPath = path.join( srcPath, 'link' );

  /* - */

  test.case = 'first';

  logger.log( 'routinePath', routinePath );

  provider.filesDelete( routinePath );

  provider.dirMake( srcPath );

  provider.fileWrite( path.join( srcPath, 'file' ), 'file' );

  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  });
  provider.pathResolveSoftLink( dstLinkPath );

  test.is( provider.fileExists( path.join( dstPath, 'file' ) ) );
  test.is( provider.isSoftLink( dstLinkPath ) );
  test.identical( provider.pathResolveSoftLink( dstLinkPath ), path.join( srcPath, 'fileNotExists' ) )

  /**/

  provider.filesDelete( routinePath );

  provider.dirMake( srcPath );
  provider.dirMake( dstPath );

  provider.fileWrite( srcLinkPath, 'file' );

  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1
  });

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  });

  test.is( !provider.isSoftLink( dstLinkPath ) );
  test.identical( provider.fileRead( dstLinkPath ), 'file' );

  /* */

  test.case = 'src - link to missing, dst - link to missing';
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })

  test.is( provider.isSoftLink( dstLinkPath ) );

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 1,
  })

  test.will = 'dstPath/link should be rewritten by srcPath/link';
  test.is( provider.isSoftLink( dstLinkPath ) );
  test.identical( provider.pathResolveSoftLink( dstLinkPath ), path.join( srcPath, 'fileNotExists' ) )


  /* */

  test.case = 'src - link to missing, dst - link to missing, resolvingSrcSoftLink - 0';
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link';
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink1 = provider.pathResolveSoftLink( dstLinkPath );
  test.identical( dstLink1, path.join( srcPath, 'link' ) );

  /* */

  test.case = 'src - link to missing, dst - link to missing, resolvingSrcSoftLink - 1';
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1,
  })
  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 1,
  })

  test.will = 'dstPath/link should be rewritten by srcPath/link';
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink1 = provider.pathResolveSoftLink( dstLinkPath );
  test.identical( dstLink1, path.join( srcPath, 'fileNotExists' ) );

  /* */

  test.case = 'src link is broken, src resolving is on'
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'file' ),
    dstPath : dstLinkPath,
    makingDirectory : 1
  })

  var records = provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 2,
  });

  test.will = 'delete dst link file';
  test.is( !provider.fileExists( dstLinkPath ) );

  /* */

  test.case = 'replace dst link by broken link'
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'fileNotExists' ),
    dstPath : srcLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })
  provider.fileWrite( path.join( dstPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'file' ),
    dstPath : dstLinkPath,
    makingDirectory : 1
  })

  var records = provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link';
  test.is( provider.fileExists( dstLinkPath ) );
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink1 = provider.pathResolveSoftLink({ filePath : dstLinkPath });
  test.identical( dstLink1, srcLinkPath );

  /* */

  test.case = 'src - link to terminal, dst - link to missing'
  provider.filesDelete( routinePath );
  provider.fileWrite( path.join( srcPath, 'file' ), 'file' );
  provider.softLink
  ({
    srcPath : path.join( srcPath, 'file' ),
    dstPath : srcLinkPath,
    makingDirectory : 1
  })
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
  })

  test.will = 'dstPath/link should be rewritten by srcPath/link'
  test.is( provider.isSoftLink( dstLinkPath ) );
  test.identical( provider.pathResolveSoftLink({ filePath : dstLinkPath }), path.join( srcPath, 'file' ) )

  /* */

  test.case = 'src - no files, dst - link to missing'
  provider.filesDelete( routinePath );
  provider.softLink
  ({
    srcPath : path.join( dstPath, 'fileNotExists' ),
    dstPath : dstLinkPath,
    allowingMissed : 1,
    makingDirectory : 1
  })

  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    mandatory : 0,
  })

  test.will = 'dstPath/link should not be rewritten by srcPath/link'
  test.is( provider.isSoftLink( dstLinkPath ) );
  var dstLink4 = provider.pathResolveSoftLink({ filePath : dstLinkPath });
  test.identical( dstLink4, path.join( dstPath, 'fileNotExists' ) );

}

//

function filesReflectLinkedExperiment( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;

  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  var srcPath = path.join( routinePath, 'src' );
  var dstPath = path.join( routinePath, 'dst' );
  var dstLinkPath = path.join( dstPath, 'link' );
  var srcLinkPath = path.join( srcPath, 'link' );
  var srcMissingPath = path.join( srcPath, 'missing' )

  /* - */

  provider.filesDelete( routinePath );
  provider.dirMake( srcPath );
  provider.softLink
  ({
    srcPath : srcMissingPath,
    dstPath : srcLinkPath,
    allowingMissed : 1,
  })
  provider.filesReflect
  ({
    reflectMap : { [ srcPath ] : dstPath },
    allowingMissed : 1,
    resolvingSrcSoftLink : 1
  });
  let got = provider.pathResolveSoftLink( dstLinkPath );
  test.identical( got, srcMissingPath )
}

filesReflectLinkedExperiment.experimental = 1;

//

function filesReflectTo( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'empty';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
    },
  });

  var extract2 = _.FileProvider.Extract();

  extract1.filesReflectTo( extract2 );
  test.identical( extract1.filesTree, extract2.filesTree );

  extract1.filesReflectTo( extract2, '/' );
  test.identical( extract1.filesTree, extract2.filesTree );

  extract1.filesReflectTo({ dstProvider : extract2, dst : '/' });
  test.identical( extract1.filesTree, extract2.filesTree );

  /* */

  test.case = 'trivial';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  var extract2 = _.FileProvider.Extract();

  extract1.filesReflectTo( extract2 );
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  extract1.filesReflectTo( extract2, '/' );
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  extract1.filesReflectTo({ dstProvider : extract2, dst : '/' });
  test.identical( extract1.filesTree, extract2.filesTree );
  extract2.filesDelete( '/' );

  /* */

  test.case = 'to current';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesReflectTo( provider, routinePath );
  var expected = [ '.', './f', './dir', './dir/df' ];
  var found = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( routinePath );

  extract1.filesReflectTo({ dstProvider : provider, dst : routinePath });
  var expected = [ '.', './f', './dir', './dir/df' ];
  var found = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( routinePath );

  /* */

  test.case = 'with srcPath current';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesReflectTo({ dstProvider : provider, dst : routinePath, src : '/dir' });
  var expected = [ '.', './df' ];
  var found = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( found, expected );
  provider.filesDelete( routinePath );

} /* end of filesReflectTo */

//

function filesReflectToWithSoftLinks( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  function rel()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.relative.apply( path.s, args );
  }

  /* - */

  test.open( 'absolute links, to extract, resolvingSrcSoftLink:0' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        // 'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink1' }],
        'terLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink2' }],
        'terLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink3' }],
        // 'dirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink1' }],
        'dirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink2' }],
        'dirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink3' }],

        'dualTerLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualTerLink1' }],
        'dualTerLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualTerLink2' }],
        // 'dualDirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink1' }],
        'dualDirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink2' }],
        'dualDirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink3' }],
        'dualDirLink4' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/terLink' }],
            'dirLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/dirLink' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:0' );

  test.open( 'relative links, to extract, resolvingSrcSoftLink:0' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink1' }],
        'terLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink2' }],
        'terLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/terLink3' }],
        // 'dirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink1' }],
        'dirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink2' }],
        'dirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink3' }],

        'dualTerLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualTerLink1' }],
        'dualTerLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualTerLink2' }],
        // 'dualDirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink1' }],
        'dualDirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink2' }],
        'dualDirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink3' }],
        'dualDirLink4' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/terLink' }],
            'dirLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/dirLink' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'relative links, to extract, resolvingSrcSoftLink:0' );

  test.open( 'relative links, to extract, resolvingSrcSoftLink:1' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/file1' }],
        'terLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink1' }],
        'dirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/file1' }],
        'dualTerLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto2/file1' }],
        // 'dualDirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink1' }],
        'dualDirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2' }],
        'dualDirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3' }],
        'dualDirLink4' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/file1' }],
            'dirLink' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 1,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'relative links, to extract, resolvingSrcSoftLink:1' );

  /* - */

  test.open( 'absolute links, to extract, resolvingSrcSoftLink:1' );

  /* - */

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        // 'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/file1' }],
        'terLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4/file1' }],
        // 'dirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dirLink1' }],
        'dirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/file1' }],
        'dualTerLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto2/file1' }],
        // 'dualDirLink1' : [{ softLink : 'extract' + extract.id + ':///src/proto/dualDirLink1' }],
        'dualDirLink2' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1/dir2' }],
        'dualDirLink3' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3' }],
        'dualDirLink4' : [{ softLink : 'extract' + extract.id + ':///src/proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : 'extract' + extract.id + ':///src/proto2/file1' }],
            'dirLink' : [{ softLink : 'extract' + extract.id + ':///src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 1,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:1' );

  debugger; return; xxx
} /* end of filesReflectToWithSoftLinks */

//

function filesReflectToWithSoftLinksRebasing( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  function abs()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.join.apply( path.s, args );
  }

  function rel()
  {
    let args = _.longSlice( arguments );
    args.unshift( routinePath );
    return path.s.relative.apply( path.s, args );
  }

  /* - */

  test.open( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:0' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }


  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 1,
  });
  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:0' );
  test.open( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:1' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dualDirLink3' : [{ softLink : '/src/proto2/dir3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }


  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 1,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 1,
  });
  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:1' );
  test.open( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:2' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : {},
        'dirLink2' : {},
        'dirLink3' : {},

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : {},
        'dualDirLink2' : {},
        'dualDirLink3' : {},
        'dualDirLink4' : {},

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 2,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 1,
  });
  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:1, resolvingSrcSoftLink:2' );

  debugger; return; xxx

  test.open( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:2' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/file1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/file1' }],
        'dualDirLink1' : [{ softLink : '/src/proto' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dualDirLink3' : [{ softLink : '/src/proto2/dir3' }],
        'dualDirLink4' : [{ softLink : '/src/proto/dir1' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '/src/proto/file1' }],
        'terLink2' : [{ softLink : '/src/proto/dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '/src/proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '/src/proto' }],
        'dirLink2' : [{ softLink : '/src/proto/dir1/dir2' }],
        'dirLink3' : [{ softLink : '/src/proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '/src/proto/terLink1' }],
        'dualTerLink2' : [{ softLink : '/src/proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '/src/proto/dirLink1' }],
        'dualDirLink2' : [{ softLink : '/src/proto/dirLink2' }],
        'dualDirLink3' : [{ softLink : '/src/proto/dirLink3' }],
        'dualDirLink4' : [{ softLink : '/src/proto2/dir3/dir4/dirLink' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '/src/proto2/file1' }],
            'dirLink' : [{ softLink : '/src/proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 2,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'absolute links, to extract, resolvingSrcSoftLink:0, rebasingLink:2' );

  test.open( 'relative links, to extract, resolvingSrcSoftLink:0, rebasingLink:1' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 1,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'relative links, to extract, resolvingSrcSoftLink:0, rebasingLink:1' );
  test.open( 'relative links, to extract, resolvingSrcSoftLink:0, rebasingLink:2' );

  /* - */

  var expected =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../file1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/file1' }],
        'dualDirLink1' : [{ softLink : '..' }],
        'dualDirLink2' : [{ softLink : '../dir1/dir2' }],
        'dualDirLink3' : [{ softLink : '../../proto2/dir3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var filesTree =
  {
    src :
    {
      proto :
      {
        'file1' : 'src/proto/file1',
        'file2' : 'src/proto/file2',

        'terLink1' : [{ softLink : '../file1' }],
        'terLink2' : [{ softLink : '../dir1/dir2/file1' }],
        'terLink3' : [{ softLink : '../../proto2/dir3/dir4/file1' }],
        'dirLink1' : [{ softLink : '..' }],
        'dirLink2' : [{ softLink : '../dir1/dir2' }],
        'dirLink3' : [{ softLink : '../../proto2/dir3' }],

        'dualTerLink1' : [{ softLink : '../terLink1' }],
        'dualTerLink2' : [{ softLink : '../../proto2/dir3/dir4/terLink' }],
        'dualDirLink1' : [{ softLink : '../dirLink1' }],
        'dualDirLink2' : [{ softLink : '../dirLink2' }],
        'dualDirLink3' : [{ softLink : '../dirLink3' }],
        'dualDirLink4' : [{ softLink : '../../proto2/dir3/dir4' }],

        dir1 :
        {
          dir2 :
          {
            'file1' : 'src/proto/dir1/dir2/file1',
            'file2' : 'src/proto/dir1/dir2/file1',
          }
        },

      },
      proto2 :
      {
        'file1' : 'src/proto2/file1',
        'file2' : 'src/proto2/file2',
        dir3 :
        {
          dir4 :
          {
            'file1' : 'src/proto2/dir3/dir4/file1',
            'file2' : 'src/proto2/dir3/dir4/file2',
            'terLink' : [{ softLink : '../../../file1' }],
            'dirLink' : [{ softLink : '../../../../proto/dir1' }],
          }
        }
      }
    },
    'f' : 'f',
    dst :
    {
      'f' : 'dst/f',
    },
  }

  var extract = new _.FileProvider.Extract({ filesTree });
  var extract2 = new _.FileProvider.Extract();
  extract.filesReflectTo
  ({
    dstProvider : extract2,
    resolvingDstSoftLink : 0,
    resolvingDstTextLink : 0,
    resolvingSrcSoftLink : 0,
    resolvingSrcTextLink : 0,
    allowingMissed : 0,
    rebasingLink : 2,
  });

  test.identical( extract2.filesTree, expected );

  /* - */

  test.close( 'relative links, to extract, resolvingSrcSoftLink:0, rebasingLink:2' );

  /* - */

  debugger; return; xxx
} /* end of filesReflectToWithSoftLinksRebasing */

//

/*
two srcs with same dst path, src2/proto/amid does not exist, dst/proto/amid exists before copy
*/

function filesReflectDstIgnoring( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* */

  test.case = 'simplest';

  var filesTree =
  {

    'src1' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

    'src2' :
    {
    },

    'dst' :
    {
      'proto' :
      {
        'amid' :
        {
        }
      }
    },

  }

  var extract = new _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree ) });

  test.case = 'simplest';
  var o =
  {
    src :
    {
      filePath :
      {
        '/src1/proto/amid' : '/dst',
        '/src2/proto/amid' : '/dst',
      },
      basePath :
      {
        '/src1/proto/amid' : '/src1',
        '/src2/proto/amid' : '/src2',
      },
    },
    recursive : 0,
    mandatory : 0,
  }

  test.mustNotThrowError( () =>
  {
    extract.filesReflect( o );
  });

  test.identical( extract.filesTree, filesTree );

  /* */

  test.case = 'simplest';

  var expected =
  {

    'src1' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

    'src2' :
    {
    },

    'dst' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

  }

  var filesTree =
  {

    'src1' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

    'src2' :
    {
    },

    'dst' :
    {
      'proto' :
      {
        'amid' :
        {
        }
      }
    },

  }

  var extract = new _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree ) });

  test.case = 'simplest';
  var o =
  {
    src :
    {
      filePath :
      {
        '/src1/proto/amid' : '/dst',
        '/src2/proto/amid' : '/dst',
      },
      basePath :
      {
        '/src1/proto/amid' : '/src1',
        '/src2/proto/amid' : '/src2',
      },
    },
    recursive : 2,
    mandatory : 0,
  }

  test.mustNotThrowError( () =>
  {
    extract.filesReflect( o );
  });

  test.identical( extract.filesTree, expected );

  /* */

  test.case = 'more files';

  var filesTree =
  {

    'src1' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

    'src2' :
    {
      'proto' : {}
    },

    'dst' :
    {
      'proto' :
      {
        'amid' :
        {
          'file' : 'file'
        }
      }
    },

  }

  var extract = new _.FileProvider.Extract({ filesTree : _.cloneJust( filesTree ) });

  var o =
  {
    src :
    {
      filePath :
      {
        'src1/proto/amid' : '.',
        'src1/proto/amid/file' : '.',
        'src1/proto' : '.',
        'src2/proto/amid' : '.',
        'src2/proto' : '.'
      },
      basePath :
      {
        'src1/proto/amid' : 'src1',
        'src1/proto/amid/file' : 'src1',
        'src1/proto' : 'src1',
        'src2/proto/amid' : 'src2',
        'src2/proto' : 'src2',
      },
      prefixPath : '/'
    },
    dst :
    {
      basePath : '.',
      prefixPath : '/dst'
    },
    recursive : 0,
    mandatory : 0,
  }

  test.mustNotThrowError( () =>
  {
    extract.filesReflect( o );
  });

  test.identical( extract.filesTree, filesTree );

  /* */

}

//

function filesDeleteTrivial( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );
  let softLinkIsSupported = context.softLinkIsSupported();

  var terminalPath = path.join( routinePath, 'terminal' );
  var dirPath = path.join( routinePath, 'dir' );

  var find = provider.filesFinder
  ({
    recursive : 2,
    includingTerminals : 1,
    includingDirs : 1,
    includingTransient : 1,
    allowingMissed : 1,
    outputFormat : 'relative',
  });

  /* */

  test.case = 'delete all files of extract';

  var extract1 = _.FileProvider.Extract
  ({
    filesTree :
    {
      f : 'f',
      dir : { df : 'df' },
    },
  });

  extract1.filesDelete( '/' );
  test.identical( extract1.filesTree, {} );

  /* */

  test.case = 'delete terminal file';
  provider.fileWrite( terminalPath, 'a' );
  var deleted = provider.filesDelete( terminalPath );
  test.identical( _.select( deleted, '*/relative' ), [ './terminal' ] );
  var stat = provider.statResolvedRead( terminalPath );
  test.identical( stat, null );

  var found = find( terminalPath );
  test.identical( found, [] );

  /* */

  test.case = 'delete empty dir';
  provider.dirMake( dirPath );
  provider.filesDelete( dirPath );
  var stat = provider.statResolvedRead( dirPath );
  test.identical( stat, null );

  /* */

  test.case = 'delete hard link';
  provider.filesDelete( routinePath );
  var dst = path.join( routinePath, 'link' );
  provider.fileWrite( terminalPath, 'a');
  provider.hardLink( dst, terminalPath );
  provider.filesDelete( dst );
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );

  /* */

  test.case = 'delete tree';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
    {
      'src' :
      {
        'a.a' : 'a',
        'b1.b' : 'b1',
        'b2.b' : 'b2x',
        'c' :
        {
          'b3.b' : 'b3x',
          'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
          'srcfile' : 'srcfile',
          'srcdir' : {},
          'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
          'srcfile-dstdir' : 'x',
        }
      }
    }

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var deleted = provider.filesDelete( routinePath );
  var expectedDeleted =
  [
    '.',
    './src',
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( routinePath ), null );
  var stat = provider.statResolvedRead( routinePath );
  test.identical( stat, null );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with filter';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
    {
      'src' :
      {
        'a.a' : 'a',
        'b1.b' : 'b1',
        'b2.b' : 'b2x',
        'c' :
        {
          'b3.b' : 'b3x',
          'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
          'srcfile' : 'srcfile',
          'srcdir' : {},
          'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
          'srcfile-dstdir' : 'x',
        }
      }
    }

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : routinePath, maskAll : { excludeAny : '/c' } } });
  var expectedDeleted =
  [
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var stat = provider.statResolvedRead( routinePath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file',
  ];
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with filter, exclude all';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
    {
      'src' :
      {
        'a.a' : 'a',
        'b1.b' : 'b1',
        'b2.b' : 'b2x',
        'c' :
        {
          'b3.b' : 'b3x',
          'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
          'srcfile' : 'srcfile',
          'srcdir' : {},
          'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
          'srcfile-dstdir' : 'x',
        }
      }
    }

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : routinePath, maskAll : { excludeAny : '/src' } } });
  var expectedDeleted =
  [
  ];
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var stat = provider.statResolvedRead( routinePath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* */

  test.case = 'delete tree with transient filter';
  var extract = _.FileProvider.Extract
  ({

    protocol : 'src',
    filesTree :
    {
      'src' :
      {
        'a.a' : 'a',
        'b1.b' : 'b1',
        'b2.b' : 'b2x',
        'c' :
        {
          'b3.b' : 'b3x',
          'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
          'srcfile' : 'srcfile',
          'srcdir' : {},
          'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
          'srcfile-dstdir' : 'x',
        }
      }
    }

  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var deleted = provider.filesDelete({ filter : { filePath : routinePath, maskTransientDirectory : { excludeAny : '/c' } } });
  var expectedDeleted =
  [
    './src/a.a',
    './src/b1.b',
    './src/b2.b',
  ]
  ;
  test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
  test.identical( provider.dirRead( routinePath ), [ 'src' ] );
  var stat = provider.statResolvedRead( routinePath );
  test.is( !!stat );
  var expectedFiles =
  [
    '.',
    './src',
    './src/c',
    './src/c/b3.b',
    './src/c/srcfile',
    './src/c/srcfile-dstdir',
    './src/c/e',
    './src/c/e/d2.d',
    './src/c/e/e1.e',
    './src/c/srcdir',
    './src/c/srcdir-dstfile',
    './src/c/srcdir-dstfile/srcdir-dstfile-file'
  ];
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.identical( files, expectedFiles );
  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* - */

  test.case = 'deletingEmptyDirs : 1';
  var extract = _.FileProvider.Extract
  ({
    protocol : 'src',
    filesTree :
    {
      'd1' :
      {
        'd2a' :
        {
          'd3' :
          {
            'd4' : { 'test' : 'test' },
          },
        },
        'd2b' :
        {
          'test' : 'test'
        },
      },
    },
  });

  test.identical( provider.protocol, 'current' );
  extract.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });

  var deleted = provider.filesDelete
  ({
    filePath : path.join( routinePath, 'd1/d2a/d3/d4' ),
    deletingEmptyDirs : 1,
  });

  var expected = [ '../..', '..', '.', './test' ];
  test.identical( _.select( deleted, '*/relative' ), expected );
  var stat = provider.statResolvedRead( path.join( routinePath, 'd1/d2a' ) );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( path.join( routinePath, 'd1/d2b' ) );
  test.is( !!stat );

  extract.finit();
  test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );

  /* - */

  if( !softLinkIsSupported )
  return;

  /* */

  test.case = 'delete soft link, resolvingSoftLink 1';
  provider.fieldPush( 'resolvingSoftLink', 1 );
  var dst = path.join( routinePath, 'link' );
  provider.fileWrite( terminalPath, ' ');
  provider.softLink( dst, terminalPath );
  provider.filesDelete( dst )
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );
  provider.fieldPop( 'resolvingSoftLink', 1 );

  /* */

  test.case = 'delete soft link, resolvingSoftLink 0';
  provider.filesDelete( routinePath );
  provider.fieldPush( 'resolvingSoftLink', 0 );
  var dst = path.join( routinePath, 'link' );
  provider.fileWrite( terminalPath, ' ');
  provider.softLink( dst, terminalPath );
  provider.filesDelete( dst )
  var stat = provider.statResolvedRead( dst );
  test.identical( stat, null );
  var stat = provider.statResolvedRead( terminalPath );
  test.is( !!stat );
  provider.fieldPop( 'resolvingSoftLink', 0 );

  /* */

}

//

function filesDelete( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;

  var routinePath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    protocol : 'src',
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })
  tree.providerRegisterTo( hub );

  //

  test.case = 'mask single directory';
  var tree2 = _.FileProvider.Extract
  ({
    protocol : 'src2',
    filesTree :
    {
      dir :
      {
        dir1 : { file : 'file' },
        dir2 : {},
      }
    }
  })
  tree2.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src2:///' : 'current://' + routinePath } });
  var filter =
  {
    maskDirectory : /dir1$/g
  }
  var got = provider.filesDelete({ filePath : routinePath, recursive : 2, throwing : 1, filter : filter });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir/dir1',
    './dir/dir1/file'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './dir',
    './dir/dir2'
  ]
  test.identical( files, expected );
  tree2.finit();

  //

  test.case = 'mask single terminal';
  var tree2 = _.FileProvider.Extract
  ({
    protocol : 'src2',
    filesTree :
    {
      dir :
      {
        file1 : 'file1',
        file2 : 'file2',
      }
    }
  })
  tree2.providerRegisterTo( hub );
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src2:///' : 'current://' + routinePath } });
  var filter =
  {
    maskTerminal : /file1$/g
  }
  var got = provider.filesDelete({ filePath : routinePath, recursive : 2, throwing : 1, filter : filter });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir/file1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './dir',
    './dir/file2',
  ]
  test.identical( files, expected );
  tree2.finit();

  //

  test.open( 'recursive' );

  test.case = 'recursive : 0';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  test.shouldThrowErrorSync( () => provider.filesDelete({ filePath : routinePath, recursive : 0 }) );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  test.will = 'nothing deleted';
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( files, expected );

  test.case = 'recursive : 1';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, recursive : 1 });
  var deleted = _.select( got, '*/relative' );
  test.will = 'only terminals from root and empty dirs'
  var expected =
  [
    './file',
    './empty1'
  ];
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  var expected =
  [
    '.',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
  ];
  test.identical( files, expected );

  test.case = 'recursive : 2';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, recursive : 2 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.close( 'recursive' );

  test.open( 'includingTerminals' );

  test.case = 'includingTerminals off';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, includingTerminals : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  test.identical( files, expected );

  test.case = 'includingTerminals off';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, includingTerminals : 0, throwing : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative'});
  test.will = 'only empty dirs should be deleted'
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  test.identical( files, expected );


  test.case = 'includingTerminals off';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, includingTerminals : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.close( 'includingTerminals' );

  test.open( 'resolvingSoftLink' );

  test.case = 'soft link to terminal';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.softLink( path.join( routinePath, 'softLink' ), path.join( routinePath, 'dir1/dir2/file' )  );
  var got = provider.filesDelete({ filePath : routinePath, resolvingSoftLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './softLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to dir';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.softLink( path.join( routinePath, 'softLink' ), path.join( routinePath, 'dir1/dir2' )  )
  var got = provider.filesDelete({ filePath : routinePath, resolvingSoftLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './softLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to terminal';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.softLink( path.join( routinePath, 'softLink' ), path.join( routinePath, 'dir1/dir2/file' )  )
  test.shouldThrowError( () => provider.filesDelete({ filePath : routinePath, resolvingSoftLink : 1 }) );

  test.close( 'resolvingSoftLink' );

  test.open( 'resolvingTextLink' );

  test.case = 'soft link to terminal';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.textLink( path.join( routinePath, 'textLink' ), path.join( routinePath, 'dir1/dir2/file' )  )
  var got = provider.filesDelete({ filePath : routinePath, resolvingTextLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './textLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to dir';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.textLink( path.join( routinePath, 'textLink' ), path.join( routinePath, 'dir1/dir2' )  )
  var got = provider.filesDelete({ filePath : routinePath, resolvingTextLink : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './textLink',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.identical( deleted, expected );

  test.case = 'soft link to terminal';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  provider.textLink( path.join( routinePath, 'textLink' ), path.join( routinePath, 'dir1/dir2/file' )  )
  test.shouldThrowError( () => provider.filesDelete({ filePath : routinePath, resolvingTextLink : 1 }) );

  test.close( 'resolvingTextLink' );

  test.open( 'writing' );

  test.case = 'writing off';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, writing : 0 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.will = 'result must include files that should be deleted when writing is on'
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative'});
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( files, expected );

  test.case = 'writing on';
  provider.filesDelete( routinePath );
  hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
  var got = provider.filesDelete({ filePath : routinePath, writing : 1 });
  var deleted = _.select( got, '*/relative' );
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative'});
  var expected =
  [
  ]
  test.identical( files, expected );

  test.close( 'writing' );

  tree.finit();

}

//

function filesDeleteAsync( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;
  let softLinkIsSupported = context.softLinkIsSupported();

  var routinePath = path.join( context.testSuitePath, test.name );
  var terminalPath = path.join( routinePath, 'terminal' );
  var dirPath = path.join( routinePath, 'dir' );
  var con = new _.Consequence().take( null )

  /* */

  .finally( () =>
  {
    test.case = 'delete terminal file';
    provider.fileWrite( terminalPath, 'a' );
    return provider.filesDelete({ filePath : terminalPath, sync : 0 })
    .then( ( deleted ) =>
    {
      test.identical( _.select( deleted, '*/relative' ), [ './terminal' ] );
      var stat = provider.statResolvedRead( terminalPath );
      test.identical( stat, null );
      return true;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'delete empty dir';
    provider.dirMake( dirPath );
    return provider.filesDelete({ filePath : dirPath, sync : 0 })
    .then( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dirPath );
      test.identical( stat, null );
      return true;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'delete hard link';
    provider.filesDelete( routinePath );
    var dst = path.join( routinePath, 'link' );
    provider.fileWrite( terminalPath, 'a');
    provider.hardLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .then( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      return true;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'delete tree';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
      {
        'src' :
        {
          'a.a' : 'a',
          'b1.b' : 'b1',
          'b2.b' : 'b2x',
          'c' :
          {
            'b3.b' : 'b3x',
            'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
            'srcfile' : 'srcfile',
            'srcdir' : {},
            'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            'srcfile-dstdir' : 'x',
          }
        }
      }

    });
    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( routinePath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
    test.identical( provider.dirRead( routinePath ), [ 'src' ] );
    return provider.filesDelete({ filePath : routinePath, sync : 0 })
    .then( ( deleted ) =>
    {
      var expectedDeleted =
      [
        '.',
        './src',
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file'
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( routinePath ), null );
      var stat = provider.statResolvedRead( routinePath );
      test.identical( stat, null );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })
  })

  /* */

  .finally( () =>
  {
    test.case = 'delete tree with filter';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
      {
        'src' :
        {
          'a.a' : 'a',
          'b1.b' : 'b1',
          'b2.b' : 'b2x',
          'c' :
          {
            'b3.b' : 'b3x',
            'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
            'srcfile' : 'srcfile',
            'srcdir' : {},
            'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            'srcfile-dstdir' : 'x',
          }
        }
      }

    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( routinePath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
    test.identical( provider.dirRead( routinePath ), [ 'src' ] );
    return provider.filesDelete({ filter : { filePath : routinePath, maskAll : { excludeAny : '/c' } }, sync : 0 })
    .then( ( deleted ) =>
    {
      var expectedDeleted =
      [
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( routinePath ), [ 'src' ] );
      var stat = provider.statResolvedRead( routinePath );
      test.is( !!stat );
      var expectedFiles =
      [
        '.',
        './src',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file',
      ];
      var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
      test.identical( files, expectedFiles );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })

  })

  /* */

  .finally( () =>
  {

    test.case = 'delete tree with filter, exclude all';
    var extract = _.FileProvider.Extract
    ({

      protocol : 'src',
      filesTree :
      {
        'src' :
        {
          'a.a' : 'a',
          'b1.b' : 'b1',
          'b2.b' : 'b2x',
          'c' :
          {
            'b3.b' : 'b3x',
            'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
            'srcfile' : 'srcfile',
            'srcdir' : {},
            'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            'srcfile-dstdir' : 'x',
          }
        }
      }

    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( routinePath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });
    test.identical( provider.dirRead( routinePath ), [ 'src' ] );
    return provider.filesDelete({ filter : { filePath : routinePath, maskAll : { excludeAny : '/src' } }, sync : 0 })
    .then( ( deleted ) =>
    {
      var expectedDeleted =
      [
      ];
      test.identical( _.select( deleted, '*/relative' ), expectedDeleted );
      test.identical( provider.dirRead( routinePath ), [ 'src' ] );
      var stat = provider.statResolvedRead( routinePath );
      test.is( !!stat );
      var expectedFiles =
      [
        '.',
        './src',
        './src/a.a',
        './src/b1.b',
        './src/b2.b',
        './src/c',
        './src/c/b3.b',
        './src/c/srcfile',
        './src/c/srcfile-dstdir',
        './src/c/e',
        './src/c/e/d2.d',
        './src/c/e/e1.e',
        './src/c/srcdir',
        './src/c/srcdir-dstfile',
        './src/c/srcdir-dstfile/srcdir-dstfile-file'
      ];
      var files = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative' });
      test.identical( files, expectedFiles );
      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })

  })

  /* */

  .finally( () =>
  {
    test.case = 'deletingEmptyDirs : 1';
    var extract = _.FileProvider.Extract
    ({
      protocol : 'src',
      filesTree :
      {
        'd1' :
        {
          'd2a' :
          {
            'd3' :
            {
              'd4' : { 't' : 't' },
            },
          },
          'd2b' :
          {
            't' : 't'
          },
        },
      },
    });

    test.identical( provider.protocol, 'current' );
    extract.providerRegisterTo( hub );
    provider.filesDelete( routinePath );
    hub.filesReflect({ reflectMap : { 'src:///' : 'current://' + routinePath } });

    return provider.filesDelete
    ({
      filePath : path.join( routinePath, 'd1/d2a/d3/d4' ),
      deletingEmptyDirs : 1,
      sync : 0
    })
    .then( ( deleted ) =>
    {
      var expected = [ '../..', '..', '.', './t' ];
      test.identical( _.select( deleted, '*/relative' ), expected );
      var stat = provider.statResolvedRead( path.join( routinePath, 'd1/d2a' ) );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( path.join( routinePath, 'd1/d2b' ) );
      test.is( !!stat );

      extract.finit();
      test.identical( _.mapKeys( hub.providersWithProtocolMap ), [ 'current' ] );
      return true;
    })
  })

  /* */

  if( !softLinkIsSupported )
  return con;

  con.finally( () =>
  {
    test.case = 'delete soft link, resolvingSoftLink 1';
    provider.fieldPush( 'resolvingSoftLink', 1 );
    var dst = path.join( routinePath, 'link' );
    provider.fileWrite( terminalPath, ' ');
    provider.softLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .then( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      provider.fieldPop( 'resolvingSoftLink', 1 );
      return true;
    })
  })

  .finally( () =>
  {
    test.case = 'delete soft link, resolvingSoftLink 0';
    provider.fieldPush( 'resolvingSoftLink', 0 );
    var dst = path.join( routinePath, 'link' );
    provider.fileWrite( terminalPath, ' ');
    provider.softLink( dst, terminalPath );
    return provider.filesDelete({ filePath : dst, sync : 0 })
    .then( ( deleted ) =>
    {
      var stat = provider.statResolvedRead( dst );
      test.identical( stat, null );
      var stat = provider.statResolvedRead( terminalPath );
      test.is( !!stat );
      provider.fieldPop( 'resolvingSoftLink', 0 );
      return true;
    })
  })

  /* */

  return con;
}

filesDeleteAsync.timeOut = 20000;

//

function filesDeleteDeletingEmptyDirs( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;
  let hub = context.hub;

  var routinePath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })

  //

  test.case = 'mask dir, deletingEmptyDirs off'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : /dir.$/g }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
  ]
  test.will = 'filtered empty dirs should not be deleted';
  test.identical( deleted, expected );

  test.case = 'mask dir, deletingEmptyDirs on'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : /dir.$/g }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file'
  ]
  test.will = 'filtered empty dirs should be deleted';
  test.identical( deleted, expected );

  test.case = 'everything is actual, deletingEmptyDirs off'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var got = provider.filesDelete({ filePath : routinePath, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'all files should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected = [];
  test.identical( files, expected )

  test.case = 'everything is actual, deletingEmptyDirs on'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var got = provider.filesDelete({ filePath : routinePath, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    '.',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'all files should be deleted + empty parent dirs of root';
  test.is( _.arrayHasAll( deleted, expected ) );

  test.case = 'exclude empty dirs, deletingEmptyDirs off'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : { excludeAny : 'empty'} }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
  ]
  test.will = 'empty dirs should be preserved';
  test.identical( deleted, expected );

  test.case = 'exclude empty dirs, deletingEmptyDirs on'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : { excludeAny : 'empty'} }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file'
  ]
  test.will = 'only terminals should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected =
  [
    '.',
    './dir1',
    './dir1/dir2',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ];
  test.will = 'empty dirs should be preserved';
  test.identical( files, expected )

  test.case = 'exclude dirs, deletingEmptyDirs off'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : { excludeAny : /dir.$/g } }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 1 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'only empty dirs and terminals should be deleted';
  test.identical( deleted, expected );
  var files = provider.filesFindRecursive({ filePath : routinePath, includingTerminals : 1, includingDirs : 1, outputFormat : 'relative' })
  var expected =
  [
    '.',
    './dir1',
    './dir1/dir2',
  ];
  test.will = 'dirs should be preserved';
  test.identical( files, expected )

  test.case = 'exclude dirs, deletingEmptyDirs on'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : { excludeAny : /dir.$/g } }
  var got = provider.filesDelete({ filePath : routinePath, filter : filter, deletingEmptyDirs : 0 });
  var deleted = _.select( got, '*/relative');
  var expected =
  [
    './file',
    './dir1/file',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  test.will = 'only terminals and empty* dirs should be deleted';
  test.identical( deleted, expected );

}

filesDeleteDeletingEmptyDirs.timeOut = 20000;

//

function filesDeleteEmptyDirs( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  var routinePath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      file : 'file',
      empty1 : {},
      dir1 :
      {
        file : 'file',
        empty2 : {},
        dir2 :
        {
          file : 'file',
          empty3 : {},
        }
      }
    }
  })

  //

  test.case = 'defaults'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteEmptyDirs( routinePath );
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( expected, got );

  //

  test.case = 'not recursive'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteEmptyDirs({ filePath : routinePath, recursive : 1 });
  /*
  {
    file : 'file',
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : /empty2$/ };
  provider.filesDeleteEmptyDirs({ filePath : routinePath, filter : filter  });
  /*
  {
    file : 'file',
    empty1 : {},
    dir :
    {
      file : 'file',
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter for not existing dir'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : 'emptyDir' };
  provider.filesDeleteEmptyDirs({ filePath : routinePath, filter : filter });
  /*
  {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'filter for terminals'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskTerminal : 'file' };
  provider.filesDeleteEmptyDirs({ filePath : routinePath, filter : filter });
  /*
  {
    file : 'file',
    dir1 :
    {
      file : 'file',
      dir2 :
      {
        file : 'file',
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob for dir'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteEmptyDirs( path.join( routinePath, '**/empty3' ) );
  /*
  {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob for terminals'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteEmptyDirs( path.join( routinePath, '**/file') );
  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'glob not existing file'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteEmptyDirs( path.join( routinePath, '**/emptyDir' ) );
  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    }
  } */
  var expected =
  [
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'resolvingSoftLink : 1'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.softLink( path.join( routinePath, 'dstPath' ), path.join( routinePath, 'dir1' ) )
  provider.filesDeleteEmptyDirs({ filePath : path.join( routinePath, 'dstPath' ), resolvingSoftLink : 1  });

  var expected =
  [
    './dstPath',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'resolvingSoftLink : 0'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.softLink( path.join( routinePath, 'dstPath' ), path.join( routinePath, 'dir1' ) )
  provider.filesDeleteEmptyDirs({ filePath : path.join( routinePath, 'dstPath' ), resolvingSoftLink : 0  });

  /* {
    file : 'file',
    empty1 : {},
    dir1 :
    {
      file : 'file',
      empty2 : {},
      dir2 :
      {
        file : 'file',
        empty3 : {},
      }
    },
    dstPath : [{ softLink : '/dir'}]
  } */

  var expected =
  [
    './dstPath',
    './file',
    './dir1',
    './dir1/file',
    './dir1/dir2',
    './dir1/dir2/file',
    './dir1/dir2/empty3',
    './dir1/empty2',
    './empty1'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  if( !Config.debug )
  {
    test.case = 'including of terminals is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : routinePath, includingTerminals : 1 }) )

    test.case = 'including of transients is not allow';
    test.shouldThrowError( () => provider.filesDeleteEmptyDirs({ filePath : routinePath, includingTransient : 1 }) )
  }
}

//

function filesDeleteTerminals( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  let routinePath = path.join( context.testSuitePath, test.name );

  var tree = _.FileProvider.Extract
  ({
    filesTree :
    {
      terminal0 : 'terminal0',
      emptyDir0 : {},
      dir1 :
      {
        terminal1 : 'terminal1',
        emptyDir1 : {},
        dir2 :
        {
          terminal2 : 'terminal2',
          emptyDir2 : {},
        }
      }
    }
  })

  //

  test.case = 'defaults'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteTerminals( routinePath );
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'recursion off'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteTerminals({ filePath : routinePath, recursive : 0 });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'recursion only first level'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteTerminals({ filePath : routinePath, recursive : 1 });
  var expected =
  [
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask terminals'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskTerminal : /terminal[01]$/ }
  provider.filesDeleteTerminals({ filePath : routinePath, filter : filter });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask dirs'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskDirectory : /dir2/ }
  provider.filesDeleteTerminals({ filePath : routinePath, filter : filter });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'mask not existing terminal'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var filter = { maskTerminal : /missing/ }
  provider.filesDeleteTerminals({ filePath : routinePath, filter : filter });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  test.case = 'glob for terminals'
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteTerminals({ filePath : path.join( routinePath, '**/terminal*' ) });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'soft link to directory';
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var linkPath = path.join( routinePath, 'linkToDir' );
  var dirPath = path.join( routinePath, 'dir1' );
  provider.softLink( linkPath, dirPath );
  test.is( provider.isSoftLink( linkPath ) )
  provider.filesDeleteTerminals({ filePath : routinePath });
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  // test.case = 'deleting empty dirs';
  // provider.filesDelete( routinePath );
  // tree.filesReflectTo( provider, routinePath );
  // provider.filesDeleteTerminals({ filePath : routinePath, deletingEmptyDirs : 1 });
  // var expected =
  // [
  //   './dir1',
  //   './dir1/dir2',
  //   './dir1/dir2/emptyDir2',
  //   './dir1/emptyDir1',
  //   './emptyDir0'
  // ]
  // var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  // test.identical( got, expected );

  //

  test.case = 'writing controls delete';
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  provider.filesDeleteTerminals({ filePath : routinePath, writing : 0 });
  var expected =
  [
    './terminal0',
    './dir1',
    './dir1/terminal1',
    './dir1/dir2',
    './dir1/dir2/terminal2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  test.case = 'broken soft link';
  provider.filesDelete( routinePath );
  tree.filesReflectTo( provider, routinePath );
  var linkPath = path.join( routinePath, 'linkToDir' );
  provider.softLink({ dstPath : linkPath, srcPath :dirPath, allowingMissed : 1 });
  test.is( provider.isSoftLink( linkPath ) )
  var expected =
  [
    './dir1',
    './dir1/dir2',
    './dir1/dir2/emptyDir2',
    './dir1/emptyDir1',
    './emptyDir0'
  ]
  provider.filesDeleteTerminals({ filePath : routinePath, allowingMissed : 1 });
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );
  provider.filesDeleteTerminals({ filePath : routinePath, allowingMissed : 0 });
  var got = provider.filesFindRecursive({ filePath : routinePath, outputFormat : 'relative', includingStem : 0 });
  test.identical( got, expected );

  //

  if( Config.debug )
  {
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : routinePath, includingDirs : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : routinePath, includingTransient : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : routinePath, includingTerminals : 0 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : routinePath, resolvingSoftLink : 1 }) )
    test.shouldThrowErrorSync( () => provider.filesDeleteTerminals({ filePath : routinePath, resolvingTextLink : 1 }) )
  }

}

//

function filesDeleteAndAsyncWrite( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  // let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  test.case = 'try to delete dir before async write will be completed';

  var cons = [];

  for( var i = 0; i < 10; i++ )
  {
    var terminalPath = path.join( routinePath, 'file' + i );
    var con = _.fileProvider.fileWrite({ filePath : terminalPath, data : terminalPath, sync : 0 });
    cons.push( con );
  }

  _.timeOut( 2, () =>
  {
    test.shouldThrowError( () =>
    {
      _.fileProvider.filesDelete( routinePath );
    });
  });

  var mainCon = new _.Consequence().take( null );
  mainCon.andKeep( cons );
  mainCon.finally( () =>
  {
    test.mustNotThrowError( () =>
    {
      _.fileProvider.filesDelete( routinePath );
    });

    var files = _.fileProvider.dirRead( routinePath );
    test.identical( files, null );
  })
  return mainCon;
}

//

function filesFindDifference( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  /* zzz Needs repair. Files tree is written with "sameTime" option enabled, but files are not having same timestamps anyway,
     probably problem is in method used by HardDrive.fileTimeSetAct
  */

  var testRoutineDir = path.join( context.testSuitePath, test.name );

  var samples =
  [

    //

    {
      name : 'simple1',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { src : { relative : '.' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './b1.b' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './b2.b' }, /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'file-file-same',
      filesTree :
      {
        initial :
        {
          'src' : 'text',
          'dst' : 'text',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : true/* , del : undefined */ },
      ],
    },

    //

    {
      name : 'file-file-different',
      filesTree :
      {
        initial :
        {
          'src' : 'text1',
          'dst' : 'text2',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : false/* , del : undefined */ },
      ],
    },

    //

    {
      name : 'file-dir',
      filesTree :
      {
        initial :
        {
          'src' : 'text1',
          'dst' : { 'd2.d' : 'd2', 'e1.e' : 'e1' },
        },
      },
      expected :
      [
        { src : { relative : './d2.d' }, /* same : undefined, */ del : true },
        { src : { relative : './e1.e' }, /* same : undefined, */ del : true },
        { src : { relative : '.' }, same : false, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'dir-file',
      filesTree :
      {
        initial :
        {
          'src' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
          'dst' : 'text1',
        },
      },
      expected :
      [
        { src : { relative : '.' }, same : false, /* del : undefined */ },
        { src : { relative : './d2.d' }, /*same : undefined, del : undefined*/ },
        { src : { relative : './e1.e' }, /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'not-same',
      filesTree :
      {

        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
            },
          },
          'dst' :
          {
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
            },
          },
        },

      },
      expected :
      [
        { src : { relative : '.' }, /*same : undefined, del : undefined, */ newer :null, older : null },
        { src : { relative : './a.a' }, /*same : undefined, del : undefined, */ newer :  { side : 'src' }, older : null },
        { src : { relative : './b1.b' }, same : true, /* del : undefined, */ newer : null, older : null   },
        { src : { relative : './b2.b' }, same : false, /*  del : undefined, */ newer : null, older : null   },
        { src : { relative : './c' }, /*same : undefined, del : undefined, */ newer : null, older : null   },
        { src : { relative : './c/d1.d' }, /* same : undefined, */ del : true, newer : { side : 'dst' }, older : null },
        { src : { relative : './c/b3.b' }, same : false, /* del : undefined, */ newer : null, older : null   },
      ],
    },

    //

    {
      name : 'levels-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { relative : './a.a', /*same : undefined, del : undefined*/ },
        { relative : './b1.b', /*same : undefined, del : undefined*/ },
        { relative : './b2.b', /*same : undefined, del : undefined*/ },
        { relative : './c', /*same : undefined, del : undefined*/ },
        { relative : './c/b3.b', /*same : undefined, del : undefined*/ },
        { relative : './c/d1.d', /*same : undefined, del : undefined*/ },
      ],
    },

    //

    {
      name : 'same-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, /* del : undefined */ },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },
        { src : { relative : './c' }, /* del : undefined */ },
        { src : { relative : './c/b3.b' }, /* del : undefined */ },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'lacking-files-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'd1.d' : 'd1',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './a.a' }, del : true },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },
        { src : { relative : './c' }, /* del : undefined */ },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
      ],
    },

    //

    {
      name : 'lacking-dir-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
        },
      },
      expected :
      [
        { relative : '.', /*same : undefined, del : undefined*/ },
        { src : { relative : './c' }, del : true },
        { src : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, /* del : undefined */ },
        { src : { relative : './b1.b' }, /* del : undefined */ },
        { src : { relative : './b2.b' }, /* del : undefined */ },

      ],
    },

    //

    {
      name : 'dir-to-file-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' : 'c',
          },
        },
      },
      expected :
      [

        { relative : '.', /*same : undefined, del : undefined*/ },

        { src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, /* del : undefined, */ same : false },
        { src : { relative : './c/b3.b' }, /* del : undefined */ },
        { src : { relative : './c/d1.d' }, /* del : undefined */ },
        { src : { relative : './c/e' }, /* del : undefined */ },
        { src : { relative : './c/e/d2.d' }, /* del : undefined */ },
        { src : { relative : './c/e/e1.e' }, /* del : undefined */ },

      ],
    },

    //

    {
      name : 'file-to-dir-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' : 'c',
            'f' : { 'f1' : 'f1' },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',

           'c' :
           {
             'b3.b' : 'b3',
             'd1.d' : 'd1',
             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
           },
          'f' : { 'f1' : { 'f11' : 'f11' } },
          },
        },
      },
      expected :
      [

        { relative : '.', src : { relative : '.' }, dst : { relative : '.' }, /*same : undefined, del : undefined*/ },

        { src : { relative : './c/b3.b' }, dst : { relative : './c/b3.b' }, del : true },
        { src : { relative : './c/d1.d' }, dst : { relative : './c/d1.d' }, del : true },
        { src : { relative : './c/e' }, dst : { relative : './c/e' }, del : true },
        { src : { relative : './c/e/d2.d' }, dst : { relative : './c/e/d2.d' }, del : true },
        { src : { relative : './c/e/e1.e' }, dst : { relative : './c/e/e1.e' }, del : true },

        { src : { relative : './a.a' }, src : { relative : './a.a' }, same : true },
        { src : { relative : './b1.b' }, src : { relative : './b1.b' }, same : true },
        { src : { relative : './b2.b' }, src : { relative : './b2.b' }, same : true },

        { src : { relative : './c' }, dst : { relative : './c' }, /* del : undefined, */ same : false },

        { src : { relative : './f' }, dst : { relative : './f' }, /* same : undefined */ },
        { src : { relative : './f/f1/f11' }, dst : { relative : './f/f1/f11' }, /* same : undefined, */ del : true },
        { src : { relative : './f/f1' }, dst : { relative : './f/f1' }, same : false },

      ],
    },

    //

    {
      name : 'not-lacking-but-masked-1',
      ends : '.b',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
            },
          },
        },
      },
      expected :
      [

        { relative : '.', newer : null, older : null },
        { relative : './a.a', del : true, newer : null, older : null },
        { relative : './c', del : true, newer : null, older : null },
        { relative : './c/b3.b', del : true, newer : null, older : null },
        { relative : './c/d1.d', del : true, newer : null, older : null },
        { relative : './c/e', del : true, newer : null, older : null },
        { relative : './c/e/d2.d', del : true, newer : null, older : null },
        { relative : './c/e/e1.e', del : true, newer : null, older : null },
        { relative : './b1.b', newer : null, older : null, same : true, link : false },
        { relative : './b2.b', newer : null, older : null, same : true, link : false }
      ],
    },

    //

    {
      name : 'complex-1',

      expected :
      [

        { relative : '.', /*same : undefined, del : undefined, */ older : null, newer : null  },

        { relative : './a.a', same : true, /*  del : undefined, */ older : null, newer : null  },
        { relative : './b1.b', same : true, /* del : undefined, */ older : null, newer : null  },
        { relative : './b2.b', same : false, /* del : undefined, */ older : null, newer : null  },

        { relative : './c', /*same : undefined, del : undefined, */ older : null, newer : null  },

        { relative : './c/dstfile.d', /* same : undefined,  */del : true, older : null, newer : { side : 'dst' } },
        { relative : './c/dstdir', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' }  },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', /* same : undefined, */ del : true, older : null, newer : { side : 'dst' } },

        { relative : './c/b3.b', same : false, /*  del : undefined, */ older : null, newer : null  },

        { relative : './c/srcfile', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },
        { relative : './c/srcfile-dstdir', same : false, /* del : undefined, */ older : null , newer : null },

        { relative : './c/e', /*same : undefined, del : undefined, */ older : null , newer : null },
        { relative : './c/e/d2.d', same : false, /* del : undefined, */ older : null, newer : null  },
        { relative : './c/e/e1.e', same : true, /* del : undefined, */ older : null, newer : null  },

        { relative : './c/srcdir', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },
        { relative : './c/srcdir-dstfile', same : false, /* del : undefined, */ older : null , newer : null },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', /*same : undefined, del : undefined, */ older : null, newer : { side : 'src' } },

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

      },

    },

    //

    {
      name : 'exclude-1',
      expected :
      [

        { relative : '.', /*same : undefined, del : undefined*/ },

        { relative : './c', /* same : undefined, */ del : true },
        { relative : './c/c1', /*  same : undefined, */ del : true },
        { relative : './c/c2', /* same : undefined, */ del : true },
        { relative : './c/c2/c22', /* same : undefined, */ del : true },

        { relative : './a', /*same : undefined, del : undefined*/ },

        { relative : './b', /*same : undefined, del : undefined*/ },
        { relative : './b/b1', same : true/* , del : undefined */ },
        { relative : './b/b2', /*same : undefined, del : undefined*/ },
        { relative : './b/b2/b22', same : true/* , del : undefined */ },
        { relative : './b/b2/x', same : true/* , del : undefined */ },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    },

   /*  {
      name : 'exclude-2',
      options :
      {
        maskAll : { excludeAny : /b/ }
      },

      expected :
      [
        { relative : '.', same : undefined, del : undefined },

        { relative : './c', same : undefined, del : true },
        { relative : './c/c1', same : undefined, del : true },
        { relative : './c/c2', same : undefined, del : true },
        { relative : './c/c2/c22', same : undefined, del : true },

        { relative : './a', same : undefined, del : undefined },


        { relative : './b', same : undefined, del : true },
        { relative : './b/b1', same : undefined, del : true },
        { relative : './b/b2', same : undefined, del : true },
        { relative : './b/b2/b22', same : undefined, del : true },
        { relative : './b/b2/x', same : undefined, del : true },

      ],

      filesTree :
      {

        initial : filesTree.exclude,

      },

    }, */

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    var dir = path.join( testRoutineDir, './tmp/sample/' + sample.name );
    test.case = sample.name;

    // _.FileProvider.Extract.readToProvider
    // ({
    //   dstProvider : _.fileProvider,
    //   dstPath : dir,
    //   filesTree : sample.filesTree,
    //   allowWrite : 1,
    //   allowDelete : 1,
    //   sameTime : 1,
    // });

    _.FileProvider.Extract({ filesTree : sample.filesTree }).filesReflectTo
    ({
      dst : dir,
      dstProvider : _.fileProvider,
      preservingTime : 1,
    });

    var o =
    {
      src : path.join( dir, 'initial/src' ),
      dst : path.join( dir, 'initial/dst' ),
      includingTerminals : 1,
      includingDirs : 1,
      recursive : 2,
      onDown : function( record ){ test.identical( _.objectIs( record ), true ); },
      onUp : function( record ){ test.identical( _.objectIs( record ), true ); },
      src : { ends : sample.ends }
    }

    _.mapExtend( o, sample.options || {} );

    var files = _.FileProvider.HardDrive();

    var got = files.filesFindDifference( o );

    var passed = true;
    passed = passed && test.contains( got, sample.expected );
    passed = passed && test.identical( got.length, sample.expected.length );

    if( !passed )
    {

      // logger.log( 'got :\n' + _.toStr( got, { levels : 3 } ) );
      // logger.log( 'expected :\n' + _.toStr( sample.expected, { levels : 3 } ) );

      // logger.log( 'got :\n' + _.toStr( got, { levels : 2 } ) );

      logger.log( 'relative :\n' + _.toStr( /*context.select*/_.select( got, '*.src.relative' ), { levels : 2 } ) );
      logger.log( 'same :\n' + _.toStr( /*context.select*/_.select( got, '*.same' ), { levels : 2 } ) );
      logger.log( 'del :\n' + _.toStr( /*context.select*/_.select( got, '*.del' ), { levels : 2 } ) );

      logger.log( 'newer :\n' + _.toStr( /*context.select*/_.select( got, '*.newer.side' ), { levels : 1 } ) );
      logger.log( 'older :\n' + _.toStr( /*context.select*/_.select( got, '*.older' ), { levels : 1 } ) );

    }

    test.case = '';

  }

}

//

function filesCopyWithAdapter( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var testRoutineDir = path.join( context.testSuitePath, test.name );

  var samples =
  [

    {
      name : 'simple-1',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory new' },
        { relative : './a.a', action : 'copied' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
      ],
    },

    //

    {
      name : 'root-exist',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : {},
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved' },
        { relative : './a.a', action : 'copied' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
      ],
    },

    //

    {
      name : 'simple-2',
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1x' },
        },
        got :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved' },
        { relative : './a.a', action : 'same' },
        { relative : './b1.b', action : 'copied' },
        { relative : './b2.b', action : 'copied' },
        { relative : './c', action : 'directory new' },
        { relative : './c/c1.c', action : 'copied' },
      ],
    },

    //

    {
      name : 'remove-source-1',
      options : { removingSource : 1, allowWrite : 1, allowDelete : 0, tryingPreserve : 0 },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1x' },
        },
        got :
        {
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '' } },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'copied', allow : true },
        { relative : './b1.b', action : 'copied', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory new', allow : true },
        { relative : './c/c1.c', action : 'copied', allow : true }
      ],
    },

    //

    {
      name : 'remove-source-files-1',
      options : { includingDirs : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1,  allowDelete : 0, filter : { ends : '.b' } },
      filesTree :
      {
        initial :
        {
          'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2', 'c' : { 'c1.c' : '', 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' } },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'e' : 'e', 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
        got :
        {
          'src' : { 'a.a' : 'a', /* 'b1.b' : 'b1', */ 'c' : { 'c1.c' : '' }, 'e' : {} },
          'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' , 'c' : { 'b3.b' : 'b3' }, 'e' : { 'b4.b' : 'b4' }, 'f1.f' : 'f1', 'g' : {}, 'h' : { 'h1.h' : 'h1' } },
        },
      },
      expected :
      [
        {
          relative : './b1.b',
          action : 'same',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './b2.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './c/b3.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        },
        {
          relative : './e/b4.b',
          action : 'copied',
          allow : true,
          srcAction : 'fileDelete',
          srcAllow : true
        }
      ],
    },



    {

      name : 'remove-sorce-files-2',
      options : { includingDirs : 0, removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowDelete : 0, filter : { ends : '.b' } },

      expected :
      [
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'same',
          allow : true,
          relative : './b1.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './b2.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './c/b3.b'
        }

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'c' :
            {
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'dstfile.d' : 'd1',
              'srcdir-dstfile' : 'x',
              'dstdir' : {},
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' }
            },
          },
        },

      },

    },



    {

      name : 'allow-rewrite-file-by-dir',
      options : { removingSourceTerminals : 1, allowWrite : 1, allowRewrite : 1, allowRewriteFileByDir : 0, allowDelete : 0, filter : { ends : '.b' } },

      expected :
      [

        {
          srcAction : 'fileDelete',
          srcAllow : false,
          reason : 'srcLooking',
          action : 'directory preserved',
          allow : true,
          relative : '.'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'same',
          allow : true,
          relative : './b1.b'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './b2.b'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'srcLooking',
          action : 'directory preserved',
          allow : true,
          relative : './c'
        },
        {
          srcAction : 'fileDelete',
          srcAllow : true,
          reason : 'srcLooking',
          action : 'copied',
          allow : true,
          relative : './c/b3.b'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/dstdir'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/dstfile.d'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/srcdir-dstfile'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'directory preserved',
          allow : false,
          relative : './c/srcfile-dstdir'
        },
        {
          srcAction : null,
          srcAllow : true,
          reason : 'dstDeleting',
          action : 'fileDelete',
          allow : false,
          relative : './c/srcfile-dstdir/srcfile-dstdir-file'
        }

      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'dstfile.d': 'd1',
              'srcdir-dstfile' : 'x',
              'dstdir' : {},
              'e': { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' }
            }
          },
          'src' :
          {
            'a.a' : 'a',
            'c' :
            {
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' }
            }
          }
        },

      },

    },

    //

    {
      name : 'levels-1',
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g' : {},
            },
          },
        },
      },
      expected :
      [

        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'same', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }

      ],
    },

    //

    {
      name : 'remove-source-files-2',
      options : { removingSourceTerminals : 1, tryingPreserve : 1 },
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {

          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e': { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g': {}
            },
          },
        },
      },
      expected :
      [

        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'same', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }

      ],
    },

    //

    {
      name : 'remove-source-2',
      options : { removingSource : 1, tryingPreserve : 0 },
      filesTree :
      {
        initial :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'g' : {},
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2',
            'c' :
            {
              'b3.b' : 'b3',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
            },
          },
        },
        got :
        {
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'd1.d' : 'd1',
              'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
              'f' : {},
              'g' : {},
            },
          },
        },
      },
      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'copied', allow : true },
        { relative : './b1.b', action : 'copied', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'copied', allow : true },
        { relative : './c/g', action : 'directory new', allow : true },
        { relative : './c/d1.d', action : 'fileDelete', allow : false },
        { relative : './c/f', action : 'fileDelete', allow : false }
      ],
    },

    //

    {

      name : 'complex-allow-delete-0',
      options : { allowRewrite : 1, allowDelete : 0 },

      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/srcfile', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'fileDelete', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/srcdir', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied', allow : true },
        { relative : './c/dstdir', action : 'fileDelete', allow : false },
        { relative : './c/dstfile.d', action : 'fileDelete', allow : false }
      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',

              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'dstfile.d' : 'd1',
              'dstdir' : {},
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            },
          },
        },

      },

    },

    //

    {

      name : 'complex-allow-all',
      options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1 },

      expected :
      [
        { relative : '.', action : 'directory preserved', allow : true },
        { relative : './a.a', action : 'same', allow : true },
        { relative : './b1.b', action : 'same', allow : true },
        { relative : './b2.b', action : 'copied', allow : true },
        { relative : './c', action : 'directory preserved', allow : true },
        { relative : './c/b3.b', action : 'copied', allow : true },
        { relative : './c/srcfile', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir', action : 'copied', allow : true },
        { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'fileDelete', allow : true },
        { relative : './c/e', action : 'directory preserved', allow : true },
        { relative : './c/e/d2.d', action : 'copied', allow : true },
        { relative : './c/e/e1.e', action : 'same', allow : true },
        { relative : './c/srcdir', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile', action : 'directory new', allow : true },
        { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'copied', allow : true },
        { relative : './c/dstdir', action : 'fileDelete', allow : true },
        { relative : './c/dstfile.d', action : 'fileDelete', allow : true }
      ],

      filesTree :
      {

        initial : filesTree.initialCommon,

        got :
        {
          'src' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
              'srcfile-dstdir' : 'x',
            },
          },
          'dst' :
          {
            'a.a' : 'a',
            'b1.b' : 'b1',
            'b2.b' : 'b2x',
            'c' :
            {
              'b3.b' : 'b3x',
              'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
              'srcfile' : 'srcfile',
              'srcfile-dstdir' : 'x',
              'srcdir' : {},
              'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
            },
          },
        },

      },

    },

    //

    // {

    //   name : 'complex-allow-only-rewrite',
    //   options : { allowRewrite : 1, allowDelete : 0, allowWrite : 0 },

    //   expected :
    //   [

    //     { relative : '.', action : 'directory preserved', },

    //     { relative : './a.a', action : 'same', },
    //     { relative : './b1.b', action : 'same', allow : true },
    //     { relative : './b2.b', action : 'cant rewrite', allow : false },

    //     { relative : './c', action : 'directory preserved', },

    //     { relative : './c/dstfile.d', action : 'deleted', allow : false },
    //     { relative : './c/dstdir', action : 'deleted', allow : false },
    //     { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

    //     { relative : './c/b3.b', action : 'cant rewrite', allow : false },

    //     { relative : './c/srcfile', action : 'copied', allow : false },
    //     { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

    //     { relative : './c/e', action : 'directory preserved', },
    //     { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
    //     { relative : './c/e/e1.e', action : 'same', },

    //     { relative : './c/srcdir', action : 'directory new', allow : false },
    //     { relative : './c/srcdir-dstfile', action : 'cant rewrite', allow : false },
    //     { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allow : false },

    //   ],

    //   filesTree :
    //   {

    //     initial : filesTree.initialCommon,

    //     got :
    //     {
    //       'src' :
    //       {
    //         'a.a' : 'a',
    //         'b1.b' : 'b1',
    //         'b2.b' : 'b2x',
    //         'c' :
    //         {
    //           'b3.b' : 'b3x',
    //           'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
    //           'srcfile' : 'srcfile',
    //           'srcdir' : {},
    //           'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
    //           'srcfile-dstdir' : 'x',
    //         },
    //       },
    //       'dst' :
    //       {
    //         'a.a' : 'a',
    //         'b1.b' : 'b1',
    //         'b2.b' : 'b2',
    //         'c' :
    //         {
    //           'b3.b' : 'b3',
    //           'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
    //           'dstfile.d' : 'd1',
    //           'dstdir' : {},
    //           'srcdir-dstfile' : 'x',
    //           'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
    //         },
    //       },
    //     },

    //   },

    // },

    //

  //   {

  //     name : 'complex-allow-only-delete',
  //     options : { allowRewrite : 0, allowDelete : 1, allowWrite : 0 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', allow : true },
  //       { relative : './b2.b', action : 'cant rewrite', allow : false },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : true },
  //       { relative : './c/dstdir', action : 'deleted', allow : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', allow : false },

  //       { relative : './c/srcfile', action : 'copied', allow : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new', allow : false },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', allow : false },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite', allow : false },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'srcdir-dstfile' : 'x',
  //             'srcfile-dstdir' : {},
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow-only-rewrite',
  //     options : { allowRewrite : 0, allowDelete : 1, allowWrite : 1 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : true },
  //       { relative : './c/dstdir', action : 'deleted', allow : true },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : true },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcfile-dstdir' : {},
  //             'srcdir' : {},
  //             'srcdir-dstfile' : 'x',
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow-rewrite-and-delete',
  //     options : { allowRewrite : 0, allowDelete : 0, allowWrite : 1 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : false },
  //       { relative : './c/dstdir', action : 'deleted', allow : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied' },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', },
  //       { relative : './c/e/e1.e', action : 'same', },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite', },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'dstfile.d' : 'd1',
  //             'dstdir' : {},
  //             'srcfile' : 'srcfile',
  //             'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
  //             'srcdir' : {},
  //             'srcdir-dstfile' : 'x',
  //           },
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {

  //     name : 'complex-not-allow',
  //     options : { allowRewrite : 0, allowDelete : 0, allowWrite : 0 },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved', },

  //       { relative : './a.a', action : 'same', },
  //       { relative : './b1.b', action : 'same', },
  //       { relative : './b2.b', action : 'cant rewrite', },

  //       { relative : './c', action : 'directory preserved', },

  //       { relative : './c/dstfile.d', action : 'deleted', allow : false },
  //       { relative : './c/dstdir', action : 'deleted', allow : false },
  //       { relative : './c/srcfile-dstdir/srcfile-dstdir-file', action : 'deleted', allow : false },

  //       { relative : './c/b3.b', action : 'cant rewrite', },

  //       { relative : './c/srcfile', action : 'copied', allow : false },
  //       { relative : './c/srcfile-dstdir', action : 'cant rewrite', allow : false },

  //       { relative : './c/e', action : 'directory preserved', },
  //       { relative : './c/e/d2.d', action : 'cant rewrite', allow : false },
  //       { relative : './c/e/e1.e', action : 'same', allow : true },

  //       { relative : './c/srcdir', action : 'directory new' },
  //       { relative : './c/srcdir-dstfile', action : 'cant rewrite' },
  //       { relative : './c/srcdir-dstfile/srcdir-dstfile-file', action : 'cant rewrite' },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.initialCommon,

  //       got :
  //       {
  //         'src' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2x',
  //           'c' :
  //           {
  //             'b3.b' : 'b3x',
  //             'e' : { 'd2.d' : 'd2x', 'e1.e' : 'd1' },
  //             'srcfile' : 'srcfile',
  //             'srcdir' : {},
  //             'srcdir-dstfile' : { 'srcdir-dstfile-file' : 'srcdir-dstfile-file' },
  //             'srcfile-dstdir' : 'x',
  //           },
  //         },
  //         'dst' :
  //         {
  //           'a.a' : 'a',
  //           'b1.b' : 'b1',
  //           'b2.b' : 'b2',
  //           'c' :
  //           {
  //             'b3.b' : 'b3',
  //             'e' : { 'd2.d' : 'd2', 'e1.e' : 'd1' },
  //             'dstfile.d' : 'd1',
  //             'dstdir' : {},
  //             'srcdir-dstfile' : 'x',
  //             'srcfile-dstdir' : { 'srcfile-dstdir-file' : 'srcfile-dstdir-file' },
  //           },
  //         },

  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-empty-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'x' },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //       },
  //       got :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory new', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-filled-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1, maskAll : 'x' },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //       },
  //       got :
  //       {
  //         'src' : { 'a.a' : 'a', 'b1.b' : 'b1', 'b2.b' : 'b2' },
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory preserved', allow : true },
  //       { relative : './a.a', action : 'deleted', allow : true },
  //       { relative : './b1.b', action : 'deleted', allow : true },
  //       { relative : './b2.b', action : 'deleted', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'filtered-out-dst-filled-1',
  //     options : { allowRewrite : 1, allowDelete : 1, allowWrite : 1 },
  //     filesTree :
  //     {
  //       initial :
  //       {
  //         'src' : {},
  //         'dst' : { 'a' : {}, 'b' : { 'b1' : 'b1', 'b2' : 'b2' } },
  //       },
  //       got :
  //       {
  //         'src' : {},
  //         'dst' : {},
  //       },
  //     },
  //     expected :
  //     [
  //       { relative : '.', action : 'directory preserved', allow : true },
  //       { relative : './a', action : 'deleted', allow : true },
  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //     ],
  //   },

  //   //

  //   {
  //     name : 'exclude-1',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { excludeAny : /b/ }
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //       { relative : './b/b2/b22', action : 'deleted', allow : true },
  //       { relative : './b/b2/x', action : 'deleted', allow : true },

  //       { relative : './c', action : 'deleted', allow : true },
  //       { relative : './c/c1', action : 'deleted', allow : true },
  //       { relative : './c/c2', action : 'deleted', allow : true },
  //       { relative : './c/c2/c22', action : 'deleted', allow : true },

  //       { relative : './a', action : 'copied', allow : true },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.exclude,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
  //         },
  //         'dst' :
  //         {
  //           'a' : 'a',
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'exclude-2',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { includeAny : /x/ }
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './b', action : 'deleted', allow : true },
  //       { relative : './b/b1', action : 'deleted', allow : true },
  //       { relative : './b/b2', action : 'deleted', allow : true },
  //       { relative : './b/b2/b22', action : 'deleted', allow : true },
  //       { relative : './b/b2/x', action : 'deleted', allow : true },

  //       { relative : './c', action : 'deleted', allow : true },
  //       { relative : './c/c1', action : 'deleted', allow : true },
  //       { relative : './c/c2', action : 'deleted', allow : true },
  //       { relative : './c/c2/c22', action : 'deleted', allow : true },

  //     ],

  //     filesTree :
  //     {

  //       initial : filesTree.exclude,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b1' : 'b1', 'b2' : { 'b22' : 'b22', 'x' : 'x' } },
  //         },
  //         'dst' :
  //         {
  //         },
  //       },

  //     },

  //   },

  //   //

  //   {
  //     name : 'softLink-1',
  //     options :
  //     {
  //       allowDelete : 1,
  //       maskAll : { excludeAny : /(^|\/)\.(?!$|\/|\.)/ },
  //     },

  //     expected :
  //     [

  //       { relative : '.', action : 'directory preserved' },

  //       { relative : './a', action : 'copied', allow : true },

  //       { relative : './b', action : 'directory new', allow : true },
  //       //{ relative : './b/.b1', action : 'copied', allow : true },
  //       { relative : './b/b2', action : 'directory new', allow : true },
  //       { relative : './b/b2/b22', action : 'copied', allow : true },

  //       { relative : './c', action : 'directory new', allow : true },
  //       { relative : './c/b2', action : 'directory new', allow : true },
  //       { relative : './c/b2/b22', action : 'copied', allow : true },

  //     ],

  //     filesTree :
  //     {
  //       initial : filesTree.softLink,
  //       got :
  //       {
  //         'src' :
  //         {
  //           'a' : 'a',
  //           'b' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
  //           'c' : { '.b1' : 'b1', 'b2' : { 'b22' : 'b22' } },
  //         },
  //         'dst' :
  //         {
  //           'a' : 'a',
  //           'b' : { 'b2' : { 'b22' : 'b22' } },
  //           'c' : { 'b2' : { 'b22' : 'b22' } },
  //         },
  //       },
  //     },

  //   },

  // //

    {
      name : 'preserve-filtered-1',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file : 'file' },
          dst : {}
        },
      },
    },

    {
      name : 'preserve-filtered-2',
      options :
      {
        allowDelete : 1,
        removingSource : 0,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { file2 : 'file2' }
        },
      },
    },
    {
      name : 'preserve-filtered-3',
      options :
      {
        allowDelete : 0,
        removingSource : 1,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst :
          {
            file2 : 'file2',
            dir : { file : 'file', file2 : 'file2' }
          },
          src : { file : 'file' }
        },
      },
    },
    {
      name : 'delete-filtered-1',
      options :
      {
        allowDelete : 0,
        removingSource : 1,
        filter :
        {
          maskAll : { includeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file2 : 'file2' },
          dst : { file : 'file', dir : { file : 'file', file2 : 'file2' } }
        },
      },
    },
    {
      name : 'delete-filtered-2',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
        filter :
        {
          maskAll : { includeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          src : { file2 : 'file2' },
          dst :
          {
          }
        },
      },
    },
    {
      name : 'preserve-all',
      options :
      {
        allowDelete : 0,
        removingSource : 0,
        filter :
        {
          maskAll : { excludeAny : /file$/ }
        },
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst :
          {
            file2 : 'file2',
            dir : { file : 'file', file2 : 'file2' }
          },
          src : { file : 'file', file2 : 'file2' }
        },
      },
    },
    {
      name : 'remove-all',
      options :
      {
        allowDelete : 1,
        removingSource : 1,
      },

      filesTree :
      {
        initial :
        {
          src : { file : 'file', file2 : 'file2' },
          dst : { dir : { file : 'file', file2 : 'file2' } }
        },
        got :
        {
          dst : {}
        },
      },
    },

  ];

  //

  for( var s = 0 ; s < samples.length ; s++ )
  {

    var sample = samples[ s ];
    if( !sample ) break;

    var dir = path.join( testRoutineDir, './tmp/sample/' + sample.name );
    test.case = sample.name;

    _.FileProvider.Extract({ filesTree : sample.filesTree }).filesReflectTo
    ({
      dst : dir,
      dstProvider : _.fileProvider,
      preservingTime : 1,
    })

    var copyOptions =
    {
      src : path.join( dir, 'initial/src' ),
      dst : path.join( dir, 'initial/dst' ),
      investigateDestination : 1,
      includingTerminals : 1,
      includingDirs : 1,
      recursive : 2,
      allowWrite : 1,
      allowRewrite : 1,
      allowDelete : 0,
    }

    _.mapExtend( copyOptions, sample.options || {} );

    var got = _.fileProvider.filesCopyWithAdapter( copyOptions );

    var treeGot = dstProvider.filesExtract( dir ).filesTree;

    var passed = true;
    if( sample.expected )
    {
      passed = passed && test.contains( got, sample.expected );
      passed = passed && test.identical( got.length, sample.expected.length );
    }
    passed = passed && test.contains( treeGot.initial, sample.filesTree.got );

    if( !passed )
    {
      logger.log( 'return :\n' + _.toStr( got, { levels : 2 } ) );
      // logger.log( 'got :\n' + _.toStr( treeGot.initial, { levels : 99 } ) );
      // logger.log( 'expected :\n' + _.toStr( sample.filesTree.got, { levels : 99 } ) );

      logger.log( 'relative :\n' + _.toStr( /*context.select*/_.select( got, '*.relative' ), { levels : 2 } ) );
      logger.log( 'action :\n' + _.toStr( /*context.select*/_.select( got, '*.action' ), { levels : 2 } ) );
      // logger.log( 'length :\n' + got.length + ' / ' + sample.expected.length );

      //logger.log( 'same :\n' + _.toStr( /*context.select*/_.select( got, '*.same' ), { levels : 2 } ) );
      //logger.log( 'del :\n' + _.toStr( /*context.select*/_.select( got, '*.del' ), { levels : 2 } ) );

    }

    test.case = '';

  }


}

filesCopyWithAdapter.timeOut = 15000;

//

function experiment( test )
{
  let context = this;
  let provider = context.provider;
  let hub = context.hub;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var src = path.join( routinePath, 'src' );
  var dst = path.join( routinePath, 'dst' );
  _.fileProvider.fileWrite( src, 'data' );
  _.fileProvider.softLink( dst, src );
  _.fileProvider.resolvingSoftLink = 1;

  var files = _.fileProvider.filesFind( dst );
  console.log( _.toStr( files, { levels : 99 } ) );

  // var got2 = _.fileProvider.filesFind( { filePath : __dirname, recursive : 2 } );
  // console.log( got2[ 0 ] );

}

experiment.experimental = 1;

//

function filesFindExperiment2( test )
{
  let context = this;
  let provider = context.provider;
  let path = context.provider.path;
  let routinePath = path.join( context.testSuitePath, 'routine-' + test.name );

  var filesTree =
  {
    a :
    {
      b :
      {
        terminal : 'terminal'
      }
    }
  }

  provider.filesDelete( routinePath );

  _.FileProvider.Extract({ filesTree : filesTree }).filesReflectTo
  ({
    dst : routinePath,
    dstProvider : provider,
    preservingTime : 1,
  })

  /*  */

  var got = provider.filesFind
  ({
    filePath : routinePath,
    recursive : 2,
    includingTransient : 1,
    includingDirs : 1,
    includingTerminals : 1,
    outputFormat : 'relative'
  })

  var expected =
  [
    '.',
    './a',
    './a/b',
    './a/b/terminal',
  ]

  test.identical( got, expected );

}

filesFindExperiment2.experimental = 1;

//

/*
qqq : not sure, why it should work differently?
*/

function filesReflectExperiment( test )
{
  let context = this;
  let path = context.provider.path;
  let provider = context.provider;

  var routinePath = path.join( context.testSuitePath, test.name );

  var srcPath = path.join( routinePath, 'src' );
  var dstPath = path.join( routinePath, 'dst' );

  var filesTree =
  {
    'src' : { a : 'a', b : { c : '' } },
    'dst' : {},
  }

  _.FileProvider.Extract({ filesTree : filesTree }).filesReflectTo
  ({
    dst : routinePath,
    dstProvider : provider,
  })

  test.case = 'directory for terminal is not created, as the result fileCopy fails'

  var filesReflectOptions =
  {
    reflectMap : { [ srcPath ] : dstPath },
    dstDeleting: 0,
    dstRewriting: 1,
    dstRewritingByDistinct: true,
    includingDirs: 0,
    includingDst: 1,
    includingTerminals: 1,
    recursive: 2,
    srcDeleting: 1
  }

  provider.filesReflect( filesReflectOptions );

  var expected =
  {
    a : 'a', b : { c : '' }
  }
  var got = provider.filesExtract( dstPath );
  test.identical( got.filesTree, expected )
}

filesReflectExperiment.experimental = 1;

// --
// declare
// --

var Self =
{

  name : 'Tools/mid/files/FilesFind/Abstract',
  abstract : 1,
  silencing : 1,
  routineTimeOut : 150000,

  onSuiteBegin,
  onSuiteEnd,
  onRoutineEnd,

  context :
  {
    provider : null,
    hub : null,
    testSuitePath : null,

    softLinkIsSupported,
    makeStandardExtract,

  },

  tests :
  {

    filesFindTrivial,
    filesFindTrivialAsync,
    filesFindMaskTerminal,
    filesFindCriticalCases,
    filesFindPreset,
    filesFind,
    filesFind2,
    filesFindRecursive,
    filesFindLinked,
    filesFindSoftLinksExtract,
    // filesFindSoftLinks, // xxx : implement rebasingLink of filesReflect first
    filesFindResolving,
    filesFindGlob,
    filesFindOn,
    filesFindBaseFromGlob,
    filesGlob,
    filesFindDistinct,
    filesFindSimplifyGlob,
    filesFindMandatoryString,
    filesFindMandatoryMap,
    filesFindExcluding,
    filesFindGlobLogic,
    filesFindGlobComplex,

    filesFindAnyPositive,
    filesFindTotalPositive,
    filesFindSeveralTotalPositive,
    filesFindTotalNegative,

    filesFindGroups,

    filesReflectEvaluate,
    filesReflectTrivial,
    filesReflectOutputFormat,
    // filesReflectMandatory, // xxx : ucomment later, after transition to willfiles
    filesReflectMutuallyExcluding,
    filesReflectWithFilter,
    filesReflect,
    filesReflectRecursive,
    filesReflectOverlap,
    filesReflectGrab,
    filesReflectorBasic,
    filesReflectWithHub,
    filesReflectLinkWithHub,
    filesReflectDeducing,
    filesReflectDstPreserving,
    filesReflectDstDeletingDirs,
    filesReflectLinked,
    filesReflectTo,
    filesReflectToWithSoftLinks,
    filesReflectToWithSoftLinksRebasing,
    filesReflectDstIgnoring,

    filesDeleteTrivial,
    filesDelete,
    filesDeleteAsync,
    filesDeleteDeletingEmptyDirs,
    filesDeleteEmptyDirs,
    filesDeleteTerminals,

    // filesDeleteAndAsyncWrite,
    // filesFindDifference,
    // filesCopyWithAdapter,

    experiment,
    filesFindExperiment2,
    filesReflectExperiment,
    filesReflectLinkedExperiment

  },

};

wTestSuite( Self );

})();
