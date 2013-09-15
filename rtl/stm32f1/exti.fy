class EXTIUnit < Unit
  class EXTI_MR < Register(32)
    self.flags(:mr,     :rw,    offset: 0, spacing: 0)
  end

  class EXTI_TR < Register(32)
    self.flags(:tr,     :rw,    offset: 0, spacing: 0)
  end

  class EXTI_SWIER < Register(32)
    self.flags(:swier,  :rw,    offset: 0, spacing: 0)
  end

  class EXTI_PR < Register(32)
    self.flags(:pr,     :rc_w1, offset: 0, spacing: 0)
  end

  self.register(:IMR,   :rw,    offset: 0x00, align: 4, impl: EXTI_MR)
  self.register(:EMR,   :rw,    offset: 0x04, align: 4, impl: EXTI_MR)
  self.register(:RTSR,  :rw,    offset: 0x08, align: 4, impl: EXTI_TR)
  self.register(:FTSR,  :rw,    offset: 0x0C, align: 4, impl: EXTI_TR)
  self.register(:SWIER, :rw,    offset: 0x10, align: 4, impl: EXTI_SWIER)
  self.register(:PR,    :rc_w1, offset: 0x14, align: 4, impl: EXTI_PR)
end
