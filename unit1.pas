unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Gl, Glu, OpenGLContext, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Types,GLext {GraphType,};

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    OpenGLControl1: TOpenGLControl;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure OpenGLControl1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure OpenGLControl1Paint(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;
f3d = record x,y,z:single end;
var
  Form1: TForm1;
  positionLight: array[0..3] of GLfloat;
  spotdirectionLight: array[0..3] of GLfloat = (0.5,0,0.5,1.0);

implementation

{$R *.lfm}

var c:single;
    zi,i,k,wd:integer;
    rotx,roty:single;
    error:longint;
    zi1,rad:Real;
    tex1,tex2:GLuint;
    bmp1,bmp2:TBitmap;
    f:boolean;
    tab: array of record x,y,z:single end;
    teren: array of array of f3d;
    t:array of record x,y,z,r,g,b:single end;
    const AmbientLight: array[0..3] of GLfloat = (0,0,0,1);
  DiffuseLight: array[0..3] of GLfloat = (0,0,0,1);
  SpecularLight: array[0..3] of GLfloat = (0,0,0,1);

{ TForm1 }

procedure JpgBmp(nazwa:String; bmp:TBitmap);
  var pic:TPicture;
begin
  pic:=TPicture.Create;
  try
    pic.LoadFromFile(nazwa);
    bmp.PixelFormat:=pf24bit;
    bmp.Width:=Pic.Graphic.Width;
    bmp.Height:=Pic.Graphic.Height;
    bmp.Canvas.Draw(0,0,Pic.Graphic);
  finally
    FreeAndNil(pic);
  end;
end;

function CreateTexture(Width,Height:Integer; pData:Pointer):GLUInt;
  var Texture:GLuint;
begin
  glEnable(GL_TEXTURE_2D);
  glGenTextures(1,@Texture);
  glBindTexture(GL_TEXTURE_2D,Texture);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D,0,3,Width,Height,0,GL_BGR,GL_UNSIGNED_BYTE,pData);
  Result:=Texture;
end;

procedure LoadTexture(NazPliku:string; var bmp:TBitmap; var texture: GLuint);
  var st:string;
      pbuf:PInteger;
begin
  if bmp<>nil then bmp.Free;
  bmp:=TBitmap.Create;
  st:=copy(NazPliku,Length(NazPliku)-2,3);
  if st='jpg' then JpgBmp(NazPliku,bmp)
              else bmp.LoadFromFile(NazPliku);
  pbuf:=PInteger(bmp.RawImage.Data);
  texture:=CreateTexture(bmp.Width,bmp.Height,pbuf);
end;



procedure bok_samochodu(zboku,z3:real;z5:integer);
begin
  LoadTexture('pojazd1.jpg',bmp1,tex1);
  glBegin(GL_POLYGON);
    glColor3f(1,1,0);
    glNormal3f(0,0,z5);
    glTexCoord2f(0, 1);
    glVertex3f(5,-2,zboku);
    glNormal3f(0,0,z5);
    glTexCoord2f(1, 0);
    glVertex3f(5,0.5,zboku);
    glNormal3f(0,0,z5);
    glTexCoord2f(1, 1);
    glVertex3f(2,0.7,zboku);
    glNormal3f(0,0,z5);
    //glColor3f(1,1,0);
    glTexCoord2f(0, 1);
    glVertex3f(0.5,3,zboku);
    glNormal3f(0,0,z5);
    glTexCoord2f(1, 0);
    glVertex3f(-5.5,3,zboku);
    glNormal3f(0,0,z5);
    glTexCoord2f(1, 0);
    glVertex3f(-6,0.5,zboku);
    glNormal3f(0,0,z5);
    glTexCoord2f(1, 1);
    glVertex3f(-6,-2,zboku);
    //ClearColor;
    glEnd;
    glDeleteTextures(1,@tex1);

    glBegin(GL_POLYGON);
    for zi:=1 to 360 do
     begin
     rad:=1.2;
     zi1:=zi*pi/180;
     glNormal3f(0,0,z5);
        glColor3f(150/255,146/255,127/255);
        glVertex3f(-4.2+rad*cos(zi1),-2+rad*sin(zi1),z3);
     end;
    glEnd;

    glBegin(GL_POLYGON);
    for zi:=1 to 360 do
     begin
     rad:=1.2;
     zi1:=zi*pi/180;
     glNormal3f(0,0,z5);
        glColor3f(150/255,146/255,127/255);
        glVertex3f(3+rad*cos(zi1),-2+rad*sin(zi1),z3);
     end;
     glEnd;
     //okna
     glBegin(GL_TRIANGLE_STRIP);
     glColor3f(0,1,0);
     glNormal3f(0,0,z5);
     glVertex3f(2,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(0.4,2.5,z3);
     glNormal3f(0,0,z5);
     glVertex3f(0.4,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-2.4,2.5,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-2.4,0.7,z3);
     glEnd;
     glBegin(GL_TRIANGLE_STRIP);
     glColor3f(0,1,0);
     glNormal3f(0,0,z5);
     glVertex3f(2,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(0.4,2.5,z3);
     glNormal3f(0,0,z5);
     glVertex3f(0.4,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-2.4,2.5,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-2.4,0.7,z3);
     glEnd;
     glBegin(GL_TRIANGLE_STRIP);
     glColor3f(0,1,0);
     glNormal3f(0,0,z5);
     glVertex3f(-2.8,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-2.8,2.5,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-5.5,0.7,z3);
     glNormal3f(0,0,z5);
     glVertex3f(-5.15,2.5,z3);
     //glVertex3f(-2.4,0.7,0.001);
     glEnd;
end;

procedure dol_tyl_samochodu;
begin
  LoadTexture('pojazd1.jpg',bmp1,tex1);
    ////dol
   glBegin(GL_TRIANGLE_STRIP);
   glColor3f(1,1,0);
     glTexCoord2f(0, 1);
     glVertex3f(5,-2,0);
     glTexCoord2f(1, 1);
     glVertex3f(5,-2,-5);
     glTexCoord2f(1, 0);
     glVertex3f(-6,-2,0);
     glTexCoord2f(0, 0);
     glVertex3f(-6,-2,-5);
   glEnd;
   //////////////tyl
   glBegin(GL_TRIANGLE_STRIP);
   glColor3f(1,1,0);
     glTexCoord2f(0, 0);
     glVertex3f(-6,-2,-5);
     glTexCoord2f(1, 0);
     glVertex3f(-6,-2,0);
     glTexCoord2f(1, 1);
     glVertex3f(-6,0.5,-5);
     glTexCoord2f(0, 1);
     glVertex3f(-6,0.5,0);
     glTexCoord2f(1, 1);
     glVertex3f(-5.5,3,-5);
     glTexCoord2f(1, 0);
     glVertex3f(-5.5,3,0);
   glEnd;
   glDeleteTextures(1,@tex1);
   /////okno_tyl
   glBegin(GL_TRIANGLE_STRIP);
     glColor4f(0,1,0,1);
     glVertex3f(-5.97,0.7,-0.3);
     glVertex3f(-5.61,2.5,-0.3);
     glVertex3f(-5.97,0.7,-4.7);
     glVertex3f(-5.61,2.5,-4.7);
   glEnd;
end;


procedure przod_gora_samochodu;
begin
   LoadTexture('pojazd1.jpg',bmp1,tex1);
   //////////////przod
   glBegin(GL_TRIANGLE_STRIP);
   glColor3f(1,1,0);
     glTexCoord2f(1, 0);
     glVertex3f(5,-2,0);
     glTexCoord2f(1, 1);
     glVertex3f(5,-2,-5);
     glTexCoord2f(0, 1);
     glVertex3f(5,0.5,0);
     glTexCoord2f(1, 0);
     glVertex3f(5,0.5,-5);
     glTexCoord2f(1, 1);
     glVertex3f(2.57,0.68,0);
     glTexCoord2f(0, 1);
     glVertex3f(2.57,0.68,-5);
     glTexCoord2f(1, 1);
     glVertex3f(0.5,3,0);
     glTexCoord2f(1, 1);
     glVertex3f(0.5,3,-5);
   glEnd;
   glDeleteTextures(1,@tex1);
   glDeleteTextures(1,@tex1);
   /////////////okno przod
   glBegin(GL_TRIANGLE_STRIP);
   glColor4f(0,1,0,1);
     glVertex3f(2.552155+0.1,0.7,-0.3);
     glVertex3f(2.552155+0.1,0.7,-4.7);
     glVertex3f(0.946120668+0.1,2.5,-0.3);
     glVertex3f(0.946120668+0.1,2.5,-4.7);
   glEnd;

   //gora
   LoadTexture('pojazd1.jpg',bmp1,tex1);
   glBegin(GL_TRIANGLE_STRIP);
     glColor3f(1,1,0);
     glTexCoord2f(1, 0);
     glVertex3f(0.5,3,0);
     glTexCoord2f(1, 1);
     glVertex3f(0.5,3,-5);
     glTexCoord2f(0, 1);
     glVertex3f(-5.5,3,0);
     glTexCoord2f(0, 1);
     glVertex3f(-5.5,3,-5);
   glEnd;
   glDeleteTextures(1,@tex1);
end;


procedure teren_wykonaj(nx,ny:integer; dz,ddx,ddy,ddz:single);
var w,wsp,pozx,pozy:single;
maksx,maksy,i,j,ii,jj,iwsp,iw,jw:integer;
begin
SetLength(teren,ny,nx);
maksx:=nx-1; maksy:=ny-1;
wsp:=5; iwsp:=trunc(wsp);
for i:=Low(teren) to High(teren)-1 do
begin
for j:=Low(teren[i]) to High(teren[i])-1 do
begin
w:=random*ddz;
pozx:=(i-maksx/2);
pozy:=(j-maksy/2);
teren[i][j].x:=pozx;
teren[i][j].y:=pozy;
teren[i][j].z:=sin(i/15+1)*cos(j/11){*sin((i+j)/3)}*dz+w;
end;
end;
end;
function il_wek(vc,vl,vp:f3d):f3d; {iloczyn wektorowy}
var w,a,b:f3d;
begin
a.x:=vl.x-vc.x; a.y:=vl.y-vc.y; a.z:=vl.z-vc.z;
b.x:=vp.x-vc.x; b.y:=vp.y-vc.y; b.z:=vp.z-vc.z;
w.x:=a.y*b.z-a.z*b.y;
w.y:=a.z*b.x-a.x*b.z;
w.z:=a.x*b.y-a.y*b.x;
il_wek:=w;
end;
procedure teren_rysuj; //wykonanie terenu z otwartej tablicy teren
var i,j:integer;
vn:f3d;
begin
for i:=Low(teren) to High(teren)-3 do //zakresy tablicy
begin
glBegin(GL_TRIANGLE_STRIP);
//glColor3f(0,0,1);
for j:=Low(teren[i]) to High(teren[i])-3 do
begin
vn:=il_wek(teren[i][j],teren[i][j+1],teren[i+1][j]);
glNormal3fv(@vn);
glColor3f(44/255,102/255,0);
//glColor3f(abs(teren[i][j].z)*2+0.1,abs(teren[i][j].z)*2+0.7,0.1);
glVertex3f(teren[i][j].x,teren[i][j].y,teren[i][j].z);
//glVertex3f(teren[i][j].x,teren[i][j].y,teren[i][j].z);
vn:=il_wek(teren[i+1][j],teren[i+1][j+1],teren[i+2][j]);
glNormal3fv(@vn);
glColor3f(44/255,102/255,0);
//glColor3f(abs(teren[i+1][j].z)*2+0.1,abs(teren[i+1][j].z)*2+0.7,0.1);
glVertex3f(teren[i+1][j].x,teren[i+1][j].y,teren[i+1][j].z);
end;
glEnd;
end;
end;

procedure drzewo_pien;
begin
  glBegin(GL_TRIANGLES); //pień drzewa, składający się z trzech wąskich trójkątów
    glColor3f(0.4,0.2,0);
    glVertex3f(0.1,0.1,0);
    glVertex3f(-0.1,0,0);
    glColor3f(0.4,0.3,0);
    glVertex3f(0,0,1);
    glColor3f(0.4,0.2,0);
    glVertex3f(-0.1,0,0);
    glVertex3f(0,-0.1,0);
    glColor3f(0.4,0.3,0);
    glVertex3f(0,0,1);
    glColor3f(0.4,0.2,0);
    glVertex3f(0,-0.1,0);
    glVertex3f(0.1,0.1,0);
    glColor3f(0.4,0.3,0);
    glVertex3f(0,0,1);
  glEnd;
end;

procedure drzewo_lisc;
begin
  glBegin(GL_Triangles); //lisc drzewa
    glColor3f(0,0.6,0);
    glVertex3f(0.1,0.1,-0.08);
    glVertex3f(-0.1,0,0.08);
    glColor3f(0,0.7,0);
    glVertex3f(0,-0.1,0);
  glEnd
end;

procedure drzewo_galezie; //gałęzie stworzone jako transformowany pień
var i:integer;
begin
  for i:=1 to 3 do
  begin
    glPushMatrix; //działamy transformacjami tak jak mnożenie macierzy
      glTranslatef(0,0,i*0.20+0.2); //4: podniesienie gałęzi wzdłuż pnia
      glRotatef(i*120,0,0,1); //3: obrócenie wokół osi Z
      glRotatef(70,1,0,0); //2: odchylenie od pionu
      glScalef(0.10*(5-i),0.10*(5-i),0.10*(5-i)); //1: skalowanie
      drzewo_pien;
    glPopMatrix; //powrót stanu transformacji do pozycji wejściowej dla kolejnej gałęzi
  end;
end;

procedure drzewo_liscie; //narysowanie 60-ciu transformowanych liści wokół drzewa
var i:integer;
begin
  for i:=1 to 60 do
  begin
    glPushMatrix; //transformacje działające na kolejny liść
      glRotatef(i*130,0,0,1);
      glTranslatef(0.15+0.1*sin(i),0.15+0.1*cos(i),i*0.013+0.25);
      glScalef(0.5,0.5,0.5);
      drzewo_lisc;
    glPopMatrix; //powrót stanu transformacji do pozycji wejściowej dla kolejnego liścia
  end;
end;

procedure generowanie_obiektu;
begin
  SetLength(t,1000);
  for i:=0 to 999 do with t[i] do
  begin
    x:=random; y:=random; z:=random;
    r:=random; g:=random; b:=random;
  end;
end;

procedure trojkaty;
begin
  glBegin(GL_TRIANGLES);
    for i:=0 to 999 do with t[i] do
    begin
      glColor3f(r,g,b);
      glVertex3f(x,y,z);
    end;
  glEnd
end;


procedure TForm1.OpenGLControl1Paint(Sender: TObject);
begin
  glMatrixMode(GL_PROJECTION); // stos projekcji
  glLoadIdentity;
  gluPerspective(100+wd,OpenGLControl1.Width/OpenGLControl1.Height,0.1,1000);
  gluLookAt(0,0,30,-2.4,2.5,0,1,0,0);
  glMatrixMode(GL_MODELVIEW); // stos modelu
  glClearColor(c,1,1,1);
  glLoadIdentity;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
  glEnable(GL_DEPTH_TEST);
  glRotatef(270,0,0,1);
  glRotatef(90,0,1,0);
  glRotatef(15,0,0,1);
  glRotatef(rotx,0,1,0);
  //glRotatef(roty,1,0,0);
  //glRotatef(k,0,1,0);
  bok_samochodu(0,0.001,1);
  bok_samochodu(-5,-5.001,-1);
  dol_tyl_samochodu;
  przod_gora_samochodu;

  glTranslatef(0,0,-19);
  glRotatef(90,1,0,0);
  teren_wykonaj(100,100,-5,0.05,0.05,0.25); //wykonanie terenu
  teren_rysuj;
  glRotatef(180,1,0,0);
  glTranslatef(5,-3,0);
  glScalef(10,10,10);
  drzewo_pien;
  drzewo_galezie;
  drzewo_liscie;
  error:=glGetError(); // pobranie numeru błędu
  label1.Caption:=gluErrorString(error);
  openglcontrol1.SwapBuffers
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inc(k); if k>1000 then k:=0;
  OpenGLControl1Paint(form1)
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  c:=0.1;
  k:=0;
  wd:=0;
  rotx:=0;
  roty:=0;
  zi:=0;
end;

procedure TForm1.OpenGLControl1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  rotx:=X;
  roty:=Y;
end;

procedure TForm1.OpenGLControl1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  if WheelDelta>0 then wd:=wd+4 else wd:=wd-4;
  if wd<-95 then wd:=-95;
  if wd>50 then wd:=50
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  glDeleteTextures(1,@tex1);
  glDeleteTextures(1,@tex2);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  c:=0.9;
end;

end.


