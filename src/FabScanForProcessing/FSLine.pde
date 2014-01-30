public class FSLine
{
  public PVector v1;
  public PVector v2;

  public FSLine(PVector _v1, PVector _v2)
  {
    v1 = _v1;
    v2 = _v2;
  }

  //NOT TESTED !!!  
  PVector intersectLineWithLine(PVector a1, PVector a2, PVector b1, PVector b2)
    // intersects line A with line B, and returns the interpolation parameters (ua and ub) that define intersection
  {
    PVector lineA = PVector.sub(a2, a1);
    PVector lineB = PVector.sub(b2, b1);
    float denom = 1.0/((lineB.y)*(lineA.x) - (lineB.x)*(lineA.y));
    float ua = ((lineB.x)*(a1.y-b1.y) - (lineB.y)*(a1.x-b1.x))*denom;
    float ub = ((lineA.x)*(a1.y-b1.y) - (lineA.y)*(a1.x-b1.x))*denom;
    PVector result = new PVector(ua, ub);
    return result;
  }


  //NOT TESTED !!!
  public PVector computeIntersection(FSLine l1, FSLine l2)
  {
    PVector result = intersectLineWithLine(l1.v1, l1.v2, l2.v1, l2.v2);
    return result;
  }

  //NOT TESTED !!!
  public PVector computeIntersectionWithLine(FSLine l2)
  {
    PVector result = intersectLineWithLine(v1, v2, l2.v1, l2.v2);
    return result;
  }
}

