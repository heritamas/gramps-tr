## A program használata

A program működéséhez telepített [Java](https://openjdk.org/install/) 
és [Gramps](https://gramps-project.org/blog/) program szükséges.

### A használat lépései
1. Exportáljunk Gramps XML-t (esetlegesen media-val együtt) a Gramps programból
2. Keressük meg az személyes adatokat tartalmazó XML fájlt.

> Ez néha nem olyan egyszerű. A media-t is tartalmazó Gramps package 
> egy tömörített állomány, amit az egyszerűség kedvéért nevezzünk át `.tar.gz` 
> kiterjesztésűre. Ha kicsomagoljuk (Linux-on egyszeűen jobbklikk, majd "Extract here")
> akkor tűnik elő a belső struktúrája. Lesz benne egy `data.gramps` állomány, ami
> éltalában egy tömörített XML. Nevezzük át `.xml.gz` kiterjesztésűre, és 
> csomagoljuk ki.
> 
> Media nélküli exportban a keletkező fájl önmagában egy tömörített XML, 
> ezt, hasonlóan az előző módszerhez, csomagoljuk ki.

3. Egy apró átalakításrra van szükség az XML fájl elején (nem tudom miért):

> A fájl elején levő 
```xml
<!DOCTYPE database PUBLIC "-//Gramps//DTD Gramps XML 1.7.1//EN"
        "http://gramps-project.org/xml/1.7.1/grampsxml.dtd">
```
szöveget  cseréljük erre:
```xml
<!DOCTYPE database PUBLIC "-//Gramps//DTD Gramps XML 1.7.1//EN"
        "grampsxml.dtd">
```

4. Ha megvan az XML-ünk (legyen a neve `gramps.xml`, _transzformálni_ kell. 

> Ehhez a `gramps-tr` projekt `transform.sh` programját használjuk. Először, 
> nézzük meg, van-e frissítése. Navigáljunk a terminálban a `gramps-tr` projekt
> könyvtárába, és adjuk ki a következő parancsot:

```shell
git pull
``` 

Ezután jöhet a konverzió:

```shell
./transform.sh -i gramps.xml -o output.txt
```

5. Ekkor az XML-ből legyártott markdown fájlok az `out/md` könyvtárba kerülnek.
6. Ezt a könyvtárat másoljuk le valami "kényelmes" helyre. 
7. A képeket az `md` könyvtár `Photos` könyvtárába helyezzük el.
8. Az Obsidian az így elkészített `md` könyvtárat vault-ként képes megnyitni.