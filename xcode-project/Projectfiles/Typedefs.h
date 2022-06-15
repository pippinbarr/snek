typedef enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
} Facing;

typedef enum {
    GOING_UP,
    GOING_DOWN,
    GOING_LEFT,
    GOING_RIGHT,
    DECELERATING_UP,
    DECELERATING_DOWN,
    DECELERATING_LEFT,
    DECELERATING_RIGHT,
    NO_TRANSLATION
} Motion;

typedef enum {
    TUTORIAL,
    PAUSE,
    PLAY,
    WARP_APPLE,
    LEVEL_CLEAR,
    GAME_OVER
} State;

typedef enum {
    PRE_MENU,
    NORMAL_MENU,
    BACKUP_HIGH_SCORES,
} MenuState;

typedef enum {
    CW,
    CCW,
    NO_ROTATION
} Rotation;

typedef enum {
    NO_TILT,
    FORWARD,
    BACKWARD,
    LEFT_SIDE,
    RIGHT_SIDE
} Tilt;