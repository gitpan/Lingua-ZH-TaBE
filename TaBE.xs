/* $File: //member/autrijus/Lingua-ZH-TaBE/TaBE.xs $ $Author: autrijus $
   $Revision: #6 $ $Change: 3611 $ $DateTime: 2003/01/18 16:01:31 $ */

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <tabe.h>

typedef struct ChuInfo *    Chu;
typedef struct ChunkInfo *  Chunk;
typedef struct TsiInfo *    Tsi;
typedef struct TsiYinInfo * TsiYin;
typedef struct TsiDB *	    TsiDB;
typedef struct TsiYinDB *   TsiYinDB;
typedef Yin *		    YinList;

static TsiDB	    TSIDB; /* last opened TsiDB */
static TsiYinDB    TSIYINDB; /* last opened TsiDB */

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE	PREFIX=tabe

TsiDB
tabeTsiDBOpen(type, db_name, flags)
	int	type
	const char *	db_name
	int	flags

int
tabeTsiInfoLookupPossibleTsiYin(tsidb, tsi)
	TsiDB	tsidb
	Tsi	tsi

TsiYinDB
tabeTsiYinDBOpen(type, db_name, flags)
	int	type
	const char *	db_name
	int	flags

int
tabeChuInfoToChunkInfo(chu)
	Chu	chu

int
tabeChunkSegmentationSimplex(tsidb, chunk)
	TsiDB	tsidb
	Chunk	chunk

int
tabeChunkSegmentationComplex(tsidb, chunk)
	TsiDB	tsidb
	Chunk	chunk

int
tabeChunkSegmentationBackward(tsidb, chunk)
	TsiDB	tsidb
	Chunk	chunk

int
tabeTsiInfoLookupZhiYin(tsidb, z)
	TsiDB	tsidb
	Tsi	z

ZhiStr
tabeYinLookupZhiList(yin)
	Yin	yin

ZuYinSymbolSequence
tabeYinToZuYinSymbolSequence(yin)
	Yin	yin

Yin
tabeZuYinSymbolSequenceToYin(str)
	ZuYinSymbolSequence	str

Zhi
tabeZuYinIndexToZuYinSymbol(idx)
	ZuYinIndex	idx

ZuYinIndex
tabeZuYinSymbolToZuYinIndex(sym)
	ZuYinSymbol	sym

ZuYinIndex
tabeZozyKeyToZuYinIndex(key)
	int	key

int
tabeZhiIsBig5Code(zhi)
	Zhi	zhi

ZhiCode
tabeZhiToZhiCode(zhi)
	Zhi	zhi

Zhi
tabeZhiCodeToZhi(code)
	ZhiCode	code

int
tabeZhiCodeToPackedBig5Code(code)
	ZhiCode	code

unsigned long int
tabeZhiCodeLookupRefCount(code)
	ZhiCode	code

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::Chu

Chu
new(package, chu, num_chunk=-1)
	const char *	    package
	ZhiStr		    chu
	int		    num_chunk
    CODE:
	RETVAL = safemalloc(sizeof(struct ChuInfo));
	RETVAL->chu = chu;
	RETVAL->num_chunk = num_chunk;
	RETVAL->chunk = NULL;
    OUTPUT:
	RETVAL

ZhiStr
chu(chu)
	Chu	chu
    CODE:
	RETVAL = chu->chu;
    OUTPUT:
	RETVAL

int
num_chunk(chu)
	Chu	chu
    CODE:
	RETVAL = chu->num_chunk;
    OUTPUT:
	RETVAL

void
chunk(chu, i=0, tmp=NULL)
	Chu	chu
	unsigned long int   i
	SV*	tmp
    PPCODE:
	if (chu->num_chunk <= 0) XSRETURN_EMPTY;
	EXTEND(SP, chu->num_chunk);
	for (; i < chu->num_chunk; i++) {
	    tmp = newSV(0);
	    sv_setref_pv(tmp, "Lingua::ZH::TaBE::Chunk", &(chu->chunk[i]));
	    PUSHs(tmp);
	}

int
ToChunkInfo(chu)
	Chu	chu
    CODE:
	RETVAL = tabeChuInfoToChunkInfo(chu);
    OUTPUT:
	RETVAL

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::Chunk

Chunk
new(package, chunk, num_tsi=-1)
	const char *	    package
	ZhiStr		    chunk
	int		    num_tsi
    CODE:
	RETVAL = safemalloc(sizeof(struct ChunkInfo));
	RETVAL->chunk = chunk;
	RETVAL->num_tsi = num_tsi;
	RETVAL->tsi = NULL;
    OUTPUT:
	RETVAL

ZhiStr
chunk(chunk)
	Chunk	chunk
    CODE:
	RETVAL = chunk->chunk;
    OUTPUT:
	RETVAL

int
num_tsi(chunk)
	Chunk	chunk
    CODE:
	RETVAL = chunk->num_tsi;
    OUTPUT:
	RETVAL

void
tsi(chunk, i=0, tmp=NULL)
	Chunk	chunk
	unsigned long int   i
	SV*	tmp
    PPCODE:
	if (chunk->num_tsi <= 0) XSRETURN_EMPTY;
	EXTEND(SP, chunk->num_tsi);
	for (; i < chunk->num_tsi; i++) {
	    tmp = newSV(0);
	    sv_setref_pv(tmp, "Lingua::ZH::TaBE::Tsi", &(chunk->tsi[i]));
	    PUSHs(tmp);
	}

int
SegmentationSimplex(chunk, tsidb=TSIDB)
	Chunk	chunk
	TsiDB	tsidb
    CODE:
	RETVAL = tabeChunkSegmentationSimplex(tsidb, chunk);
    OUTPUT:
	RETVAL

int
SegmentationComplex(chunk, tsidb=TSIDB)
	Chunk	chunk
	TsiDB	tsidb
    CODE:
	RETVAL = tabeChunkSegmentationComplex(tsidb, chunk);
    OUTPUT:
	RETVAL

int
SegmentationBackward(chunk, tsidb=TSIDB)
	Chunk	chunk
	TsiDB	tsidb
    CODE:
	RETVAL = tabeChunkSegmentationBackward(tsidb, chunk);
    OUTPUT:
	RETVAL

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::Tsi

Tsi
new(package, tsi, refcount=0, yinnum=0)
	const char *	    package
	ZhiStr		    tsi
	unsigned long int   refcount
	unsigned long int   yinnum
    CODE:
	RETVAL = safemalloc(sizeof(struct TsiInfo));
	RETVAL->tsi = tsi;
	RETVAL->refcount = refcount;
	RETVAL->yinnum = yinnum;
	RETVAL->yindata = NULL;
    OUTPUT:
	RETVAL

ZhiStr
tsi(tsi)
	Tsi	tsi
    CODE:
	RETVAL = tsi->tsi;
    OUTPUT:
	RETVAL

unsigned long int
refcount(tsi)
	Tsi	tsi
    CODE:
	RETVAL = tsi->refcount;
    OUTPUT:
	RETVAL

unsigned long int
yinnum(tsi)
	Tsi	tsi
    CODE:
	RETVAL = tsi->yinnum;
    OUTPUT:
	RETVAL

void
yindata(tsi, i=0, tmp=NULL)
	Tsi		    tsi
	unsigned long int   i
	SV*	tmp
    PPCODE:
	if (tsi->yinnum <= 0) XSRETURN_EMPTY;
	EXTEND(SP, tsi->yinnum);
	for (; i < tsi->yinnum; i++) {
	    tmp = newSV(0);
	    sv_setref_uv(tmp, "Lingua::ZH::TaBE::Yin", tsi->yindata[i]);
	    PUSHs(tmp);
	}

int
LookupPossibleTsiYin(tsi, tsidb=TSIDB)
	Tsi	tsi
	TsiDB	tsidb
    CODE:
	RETVAL = tabeTsiInfoLookupPossibleTsiYin(tsidb, tsi);
    OUTPUT:
	RETVAL

int
LookupZhiYin(z, tsidb=TSIDB)
	Tsi	z
	TsiDB	tsidb
    CODE:
	RETVAL = tabeTsiInfoLookupZhiYin(tsidb, z);
    OUTPUT:
	RETVAL

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::TsiYin

TsiYin
new(package, yin, yinlen=0, tsinum=0, tsidata=NULL)
	const char *	    package
	YinList		    yin
	unsigned long int   yinlen
	unsigned long int   tsinum
	ZhiStr		    tsidata
    CODE:
	RETVAL = safemalloc(sizeof(struct TsiYinInfo));
	RETVAL->yin = yin;
	RETVAL->yinlen = strlen((char *)yin);
	RETVAL->tsinum = tsinum;
	RETVAL->tsidata = tsidata;
    OUTPUT:
	RETVAL

unsigned long int
yinlen(tsiyin)
	TsiYin	tsiyin
    CODE:
	RETVAL = tsiyin->yinlen;
    OUTPUT:
	RETVAL

SV *
yin(tsiyin)
	TsiYin	tsiyin
    CODE:
	RETVAL = newSVpvn((char *)tsiyin->yin, tsiyin->yinlen);
    OUTPUT:
	RETVAL

unsigned long int
tsinum(tsiyin)
	TsiYin	tsiyin
    CODE:
	RETVAL = tsiyin->tsinum;
    OUTPUT:
	RETVAL

void
tsidata(tsiyin, i=0, tmp=NULL, tsi=NULL)
	TsiYin		    tsiyin
	unsigned long int   i
	Tsi		    tsi
	SV *		    tmp
    PPCODE:
	if (tsiyin->tsinum <= 0) XSRETURN_EMPTY;
	EXTEND(SP, tsiyin->tsinum);
	for (; i < tsiyin->tsinum; i++) {
	    tsi = safemalloc(sizeof(struct TsiInfo));
	    strncpy(
		tsi->tsi, 
		(char *)tsiyin->tsidata+((i * tsiyin->yinlen))*2,
		tsiyin->yinlen*2+1
	    );
	    tsi->refcount = -1;
	    tsi->yinnum = -1;
	    tsi->yindata = NULL;
	    sv_setref_pv(tmp, "Lingua::ZH::TaBE::Tsi", &(tsi));
	    PUSHs(tmp);
	}

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::TsiDB

TsiDB
new(package, type, db_name, flags)
	const char *	package
	int	type
	const char *	db_name
	int	flags
    CODE:
	RETVAL = TSIDB = tabeTsiDBOpen(type, db_name, flags);
    OUTPUT:
	RETVAL

int
type(tsidb)
	TsiDB	tsidb
    CODE:
	RETVAL = tsidb->type;
    OUTPUT:
	RETVAL

int
flags(tsidb)
	TsiDB	tsidb
    CODE:
	RETVAL = tsidb->flags;
    OUTPUT:
	RETVAL

char *
db_name(tsidb)
	TsiDB	tsidb
    CODE:
	RETVAL = tsidb->db_name;
    OUTPUT:
	RETVAL

void
Close(tsidb)
	TsiDB	tsidb
    CODE:
	tsidb->Close(tsidb);

int
RecordNumber(tsidb)
	TsiDB	tsidb
    CODE:
	RETVAL = tsidb->RecordNumber(tsidb);
    OUTPUT:
	RETVAL

int
Put(tsidb, tsi)
	TsiDB	tsidb
	Tsi	tsi
    CODE:
	RETVAL = tsidb->Put(tsidb, tsi);
    OUTPUT:
	RETVAL

int
Get(tsidb, tsi)
	TsiDB	tsidb
	Tsi	tsi
    CODE:
	RETVAL = tsidb->Get(tsidb, tsi);
    OUTPUT:
	RETVAL

int
CursorSet(tsidb, tsi, set_range)
	TsiDB	tsidb
	Tsi	tsi
	int	set_range
    CODE:
	RETVAL = tsidb->CursorSet(tsidb, tsi, set_range);
    OUTPUT:
	RETVAL

int
CursorNext(tsidb, tsi)
	TsiDB	tsidb
	Tsi	tsi
    CODE:
	RETVAL = tsidb->CursorNext(tsidb, tsi);
    OUTPUT:
	RETVAL

int
CursorPrev(tsidb, tsi)
	TsiDB	tsidb
	Tsi	tsi
    CODE:
	RETVAL = tsidb->CursorPrev(tsidb, tsi);
    OUTPUT:
	RETVAL

MODULE = Lingua::ZH::TaBE   PACKAGE = Lingua::ZH::TaBE::TsiYinDB

TsiYinDB
new(package, type, db_name, flags)
	const char *	package
	int	type
	const char *	db_name
	int	flags
    CODE:
	RETVAL = TSIYINDB = tabeTsiYinDBOpen(type, db_name, flags);
    OUTPUT:
	RETVAL

int
type(tsidb)
	TsiYinDB	tsidb
    CODE:
	RETVAL = tsidb->type;
    OUTPUT:
	RETVAL

int
flags(tsidb)
	TsiYinDB	tsidb
    CODE:
	RETVAL = tsidb->flags;
    OUTPUT:
	RETVAL

char *
db_name(tsidb)
	TsiYinDB	tsidb
    CODE:
	RETVAL = tsidb->db_name;
    OUTPUT:
	RETVAL

void
Close(tsidb)
	TsiYinDB	tsidb
    CODE:
	tsidb->Close(tsidb);

int
RecordNumber(tsidb)
	TsiYinDB	tsidb
    CODE:
	RETVAL = tsidb->RecordNumber(tsidb);
    OUTPUT:
	RETVAL

int
Put(tsidb, tsiyin)
	TsiYinDB	tsidb
	TsiYin		tsiyin
    CODE:
	RETVAL = tsidb->Put(tsidb, tsiyin);
    OUTPUT:
	RETVAL

int
Get(tsidb, tsiyin)
	TsiYinDB	tsidb
	TsiYin		tsiyin
    CODE:
	RETVAL = tsidb->Get(tsidb, tsiyin);
    OUTPUT:
	RETVAL

int
CursorSet(tsidb, tsiyin, set_range)
	TsiYinDB	tsidb
	TsiYin		tsiyin
	int	set_range
    CODE:
	RETVAL = tsidb->CursorSet(tsidb, tsiyin, set_range);
    OUTPUT:
	RETVAL

int
CursorNext(tsidb, tsiyin)
	TsiYinDB	tsidb
	TsiYin		tsiyin
    CODE:
	RETVAL = tsidb->CursorNext(tsidb, tsiyin);
    OUTPUT:
	RETVAL

int
CursorPrev(tsidb, tsiyin)
	TsiYinDB	tsidb
	TsiYin		tsiyin
    CODE:
	RETVAL = tsidb->CursorPrev(tsidb, tsiyin);
    OUTPUT:
	RETVAL
