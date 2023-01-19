using UnityEngine;

namespace TestingProject3D
{
    public class ShaderObjectHighlight : MonoBehaviour
    {
        public Material material;

        Camera cam;

        void Start() => cam = Camera.main;

        // Update is called once per frame
        void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                Ray ray = cam.ScreenPointToRay(Input.mousePosition);

                if (Physics.Raycast(ray, out RaycastHit hit))
                {
                    if (material)
                    {
                        Vector4 pos = new Vector4(hit.point.x, hit.point.y, hit.point.z, 0);
                        material.SetVector("_Position", pos);
                    }
                }
            }
        }
    }
}
