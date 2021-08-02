
using UnityEngine;

public class MoveAnimationByKey : MonoBehaviour
{
  [SerializeField] float forwardAmount = 0.1f;
  [SerializeField] float backAmount = 0.01f;
  [SerializeField] float runningAmount = 0.1f;
  [SerializeField] float rotateAmount = 2.0f;

  Animator animator;
  public bool enable = true;

  enum AnimState
  {
    None,
    WalkFront,
    WalkBack,
    Run
  }
  AnimState state = AnimState.None;
  void Start()
  {
    animator = GetComponent<Animator>();
  }

  void Update()
  {
    if (!Input.anyKey || !enable)
    {
      SetState(AnimState.None);
      return;
    }

    bool isRunning = Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift);

    if (Input.GetKey("up"))
    {
      if (isRunning) SetState(AnimState.Run);
      else SetState(AnimState.WalkFront);
    }
    else if (Input.GetKey("down")) SetState(AnimState.WalkBack);


    if (Input.GetKey("left"))
    {
      transform.Rotate(0, -rotateAmount, 0);
      if (state == AnimState.None) SetState(AnimState.WalkFront);
    }
    else if (Input.GetKey("right"))
    {
      transform.Rotate(0, rotateAmount, 0);
      if (state == AnimState.None) SetState(AnimState.WalkFront);
    }

    if (state == AnimState.Run) transform.position += transform.forward * runningAmount;
    else if (state == AnimState.WalkFront) transform.position += transform.forward * forwardAmount;
    else if (state == AnimState.WalkBack) transform.position -= transform.forward * backAmount;
  }

  void SetState(AnimState state)
  {
    this.state = state;
    animator.ResetTrigger("Idle");
    animator.ResetTrigger("Run");
    animator.ResetTrigger("WalkFront");
    animator.ResetTrigger("WalkBack");
    if (state == AnimState.None) animator.SetTrigger("Idle");
    else if (state == AnimState.WalkFront) animator.SetTrigger("WalkFront");
    else if (state == AnimState.WalkBack) animator.SetTrigger("WalkBack");
    else if (state == AnimState.Run) animator.SetTrigger("Run");
  }
}