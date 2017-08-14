using System.Collections;
using System.Collections.Generic;
using Celf;
using UnityEngine;

public class TransformTest : MonoBehaviour
{
    public Transform parent;

    private GameObject root;
    private GameObject head;

    private GameObject attachPoint;
    void Awake()
    {
        root = Instantiate(Resources.Load<GameObject>("zj_daoshi_biaonan_body01"));
        head = Instantiate(Resources.Load<GameObject>("zj_daoshi_biaonan_face01"));
        root.transform.parent = parent;
        attachPoint = FindGameObject(root, "Bip001 Head");
    }

    public GameObject FindGameObject(GameObject parent, string childName)
    {
        if (parent.name == childName)
        {
            return parent;
        }

        if (parent.transform.childCount < 1)
        {
            return null;
        }

        GameObject obj = null;
        for (int i = 0; i < parent.transform.childCount; i++)
        {
            GameObject go = parent.transform.GetChild(i).gameObject;
            obj = FindGameObject(go, childName);
            if (obj != null)
            {
                break;
            }
        }
        return obj;
    }

    private void TestParent()
    {
        head.transform.parent = attachPoint.transform;
        print(head.transform.position);
    }

    private void TestParent2()
    {
        head.transform.SetParent(attachPoint.transform, false);
    }

    private void TestParent3()
    {
        Matrix4x4 tt = attachPoint.transform.worldToLocalMatrix;
        head.transform.position = tt * head.transform.position;
        print(head.transform.position);
    }

    private void OnGUI()
    {
        if (GUI.Button(new Rect(0, 0, 100, 30), "Refresh1"))
        {
            //TestParent();
            UIAtlas ATALS = gameObject.GetComponentInChildren<UIAtlas>();
            if (ATALS == null)
            {
                Debug.Log("_________________error");
            }
            else
            {
                Debug.Log("_________________right");
            }

        }

        if (GUI.Button(new Rect(200, 0, 100, 30), "Refresh2"))
        {
            TestParent2();
        }


        if (GUI.Button(new Rect(400, 0, 100, 30), "Refresh3"))
        {
            TestParent3();
        }
    }
}
