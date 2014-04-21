staload "lib/either.sats"

implement{a}{b} t_left (x) = Left (x)
implement{a}{b} t_right (x) = Right (x)

implement{a}{b} vt_left (x) = Left_vt (x)
implement{a}{b} vt_right (x) = Right_vt (x)
