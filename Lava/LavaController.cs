using UnityEngine;

namespace TestingProject3D
{
    [ExecuteAlways]
    public class LavaController : MonoBehaviour
    {
        [SerializeField] Material material;
        [SerializeField] Light pointLight;
        int ff = 0;

        // Update is called once per frame
        void Update()
        {
            var timeCos = (Mathf.PingPong(Time.time, 3) + 1) * 0.5f;
            material.SetFloat("_TimeInput", timeCos);
            pointLight.intensity = timeCos;
        }
    }
}
