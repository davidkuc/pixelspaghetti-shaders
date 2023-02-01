using System.Collections.Generic;
using UnityEngine;

namespace TestingProject3D
{
    [ExecuteAlways]
    public class LavaController : MonoBehaviour
    {
        [SerializeField] Material material;
        [SerializeField] List<Light> pointLights;

        void Update()
        {
            var timeCos = (Mathf.Clamp(Mathf.PingPong(Time.time, 5) / 5, 0.5f, 1.5f));
            material.SetFloat("_TimeInput", timeCos);

            foreach (var item in pointLights)
            {
                item.intensity = timeCos;
            }
        }
    }
}
