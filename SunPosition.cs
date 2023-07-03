using UnityEngine;

public class SunPosition : MonoBehaviour
{
    public float sunDistance;
    public Camera cam;
    public Material sunShafts;
    // Update is called once per frame
    void LateUpdate()
    {
        Shader.SetGlobalVector("_SunPos", cam.WorldToViewportPoint(transform.position));
        float Dis = Vector2.Distance(new Vector2(cam.transform.position.x, cam.transform.position.y), new Vector2(transform.position.x, transform.position.y));
        sunShafts.SetFloat("_SunVisible", 1 - (Mathf.Clamp(Dis-3, 0, sunDistance) / sunDistance));
;    }
}
