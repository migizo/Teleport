using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
  [SerializeField] MoveAnimationByKey moveByKey;
  Teleport teleport;
  void Start()
  {
    teleport = GetComponent<Teleport>();
  }

  void Update()
  {
    if (Input.GetKey(KeyCode.Space)) StartCoroutine(StartTeleport());
  }

  IEnumerator StartTeleport()
  {
    moveByKey.enable = false;

    float disappearInterval = 1;
    teleport.Disappear();
    yield return new WaitForSeconds(teleport.totalTime + disappearInterval);
    teleport.Appear(new Vector3(Random.insideUnitSphere.x * 10, 0, Random.insideUnitSphere.z * 10));

    moveByKey.enable = true;
  }
}
