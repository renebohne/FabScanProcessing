public class FSLine
{
  public PVector v1;
  public PVector v2;

  public float a=0.0f;
  public float b=0.0f;

  public FSLine()
  {
  }

  public FSLine(PVector _v1, PVector _v2)
  {
    v1 = _v1;
    v2 = _v2;
    FSLine l = computeLineFromPoints(v1, v2);
    a = l.a;
    b = l.b;
  }

  public FSLine computeLineFromPoints(PVector p1, PVector p2)
  {
    FSLine l = new FSLine();
    l.a = (p2.z-p1.z)/(p2.x-p1.x);
    l.b = p1.z-l.a*p1.x;
    return l;
  }

  PVector computeIntersectionOfLines(FSLine l1, FSLine l2)
  {
    //intersection of the two coplanar lines
    PVector i = new PVector(0,0,0);
    i.x = (l2.b-l1.b)/(l1.a-l2.a);
    i.z = l2.a*i.x+l2.b;
    return i;
  }
  
  public PVector computeIntersectionWithLine(FSLine l)
  {
    return computeIntersectionOfLines(this, l);
  }
  
  public String toString()
  {
    String ret = "[";
    ret += a +","+b+"]";
    return ret;
  }
}

