# 100 MHz Clock:
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33}           [get_ports {clock}]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clock}]

# Switches:
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {switches[0] }]; # Right-most switch.
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {switches[1] }]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {switches[2] }]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {switches[3] }]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {switches[4] }]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {switches[5] }]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {switches[6] }]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {switches[7] }]
set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS18} [get_ports {switches[8] }]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS18} [get_ports {switches[9] }]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {switches[10]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {switches[11]}]
set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33} [get_ports {switches[12]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {switches[13]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {switches[14]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {switches[15]}]; # Left-most switch.

# LEDs:
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {leds[0] }]; # Right-most LED.
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {leds[1] }]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {leds[2] }]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {leds[3] }]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {leds[4] }]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {leds[5] }]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {leds[6] }]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {leds[7] }]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {leds[8] }]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {leds[9] }]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {leds[10]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {leds[11]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {leds[12]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {leds[13]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {leds[14]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {leds[15]}]; # Left-most LED.

# RGB LEDs:
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {LED16_B}]
set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {LED16_G}]
set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {LED16_R}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {LED17_B}]
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {LED17_G}]
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {LED17_R}]

# Seven-Segment Displays:
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {decimal_point}]; # Decimal Point.
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {segments[0]  }]; # Segment A.
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {segments[1]  }]; # Segment B.
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {segments[2]  }]; # Segment C.
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {segments[3]  }]; # Segment D.
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {segments[4]  }]; # Segment E.
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {segments[5]  }]; # Segment F.
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {segments[6]  }]; # Segment G.
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {anodes[0]    }]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {anodes[1]    }]
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports {anodes[2]    }]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {anodes[3]    }]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {anodes[4]    }]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {anodes[5]    }]
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports {anodes[6]    }]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {anodes[7]    }]

# CPU Reset Button:
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports {reset_n}]

# Buttons:
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {btnc}]; # Center Button.
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {btnu}]; # Up Button.
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {btnd}]; # Down Button.
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {btnl}]; # Left Button.
set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {btnr}]; # Right Button.

# PMOD Header JA:
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {ja[1] }]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {ja[2] }]
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {ja[3] }]
set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {ja[4] }]
set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {ja[7] }]
set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ja[8] }]
set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {ja[9] }]
set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {ja[10]}]

# PMOD Header JB:
set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {jb[1] }]
set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {jb[2] }]
set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {jb[3] }]
set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {jb[4] }]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {jb[7] }]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {jb[8] }]
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {jb[9] }]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {jb[10]}]

# PMOD Header JC:
set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {jc[1] }]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {jc[2] }]
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {jc[3] }]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {jc[4] }]
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS33} [get_ports {jc[7] }]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {jc[8] }]
set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {jc[9] }]
set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {jc[10]}]

# PMOD Header JD:
set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {jd[1] }]
set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {jd[2] }]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {jd[3] }]
set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {jd[4] }]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {jd[7] }]
set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {jd[8] }]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {jd[9] }]
set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {jd[10]}]

# PMOD Header JXADC:
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {xa_n[1]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {xa_p[1]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {xa_n[2]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {xa_p[2]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {xa_n[3]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {xa_p[3]}]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {xa_n[4]}]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {xa_p[4]}]

# VGA Connector:
set_property -dict {PACKAGE_PIN A3  IOSTANDARD LVCMOS33} [get_ports {vga_r[0]}]
set_property -dict {PACKAGE_PIN B4  IOSTANDARD LVCMOS33} [get_ports {vga_r[1]}]
set_property -dict {PACKAGE_PIN C5  IOSTANDARD LVCMOS33} [get_ports {vga_r[2]}]
set_property -dict {PACKAGE_PIN A4  IOSTANDARD LVCMOS33} [get_ports {vga_r[3]}]
set_property -dict {PACKAGE_PIN C6  IOSTANDARD LVCMOS33} [get_ports {vga_g[0]}]
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS33} [get_ports {vga_g[1]}]
set_property -dict {PACKAGE_PIN B6  IOSTANDARD LVCMOS33} [get_ports {vga_g[2]}]
set_property -dict {PACKAGE_PIN A6  IOSTANDARD LVCMOS33} [get_ports {vga_g[3]}]
set_property -dict {PACKAGE_PIN B7  IOSTANDARD LVCMOS33} [get_ports {vga_b[0]}]
set_property -dict {PACKAGE_PIN C7  IOSTANDARD LVCMOS33} [get_ports {vga_b[1]}]
set_property -dict {PACKAGE_PIN D7  IOSTANDARD LVCMOS33} [get_ports {vga_b[2]}]
set_property -dict {PACKAGE_PIN D8  IOSTANDARD LVCMOS33} [get_ports {vga_b[3]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {vga_hs  }]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports {vga_vs  }]

# Micro SD Connector:
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {SD_RESET }]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS33} [get_ports {SD_CD    }]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {SD_SCK   }]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {SD_CMD   }]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {SD_DAT[0]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {SD_DAT[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS33} [get_ports {SD_DAT[2]}]
set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports {SD_DAT[3]}]

# Accelerometer:
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports {ACL_MISO  }]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {ACL_MOSI  }]
set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports {ACL_SCLK  }]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports {ACL_CSN   }]
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {ACL_INT[1]}]
set_property -dict {PACKAGE_PIN C16 IOSTANDARD LVCMOS33} [get_ports {ACL_INT[2]}]

# Temperature Sensor:
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {TMP_SCL}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {TMP_SDA}]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports {TMP_INT}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {TMP_CT }]

# Omnidirectional Microphone:
set_property -dict {PACKAGE_PIN J5 IOSTANDARD LVCMOS33} [get_ports {M_CLK  }]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {M_DATA }]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {M_LRSEL}]

# PWM Audio Amplifier:
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {AUD_PWM}]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {AUD_SD }]

# USB-RS232 Interface:
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports {UART_TXD_IN }]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {UART_RXD_OUT}]
set_property -dict {PACKAGE_PIN D3 IOSTANDARD LVCMOS33} [get_ports {UART_CTS    }]
set_property -dict {PACKAGE_PIN E5 IOSTANDARD LVCMOS33} [get_ports {UART_RTS    }]

# USB HID (PS/2):
set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports {PS2_CLK }]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {PS2_DATA}]

# SMSC Ethernet PHY:
set_property -dict {PACKAGE_PIN C9  IOSTANDARD LVCMOS33} [get_ports {ETH_MDC   }]
set_property -dict {PACKAGE_PIN A9  IOSTANDARD LVCMOS33} [get_ports {ETH_MDIO  }]
set_property -dict {PACKAGE_PIN B3  IOSTANDARD LVCMOS33} [get_ports {ETH_RSTN  }]
set_property -dict {PACKAGE_PIN D9  IOSTANDARD LVCMOS33} [get_ports {ETH_CRSDV }]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {ETH_RXERR }]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[0]}]
set_property -dict {PACKAGE_PIN D10 IOSTANDARD LVCMOS33} [get_ports {ETH_RXD[1]}]
set_property -dict {PACKAGE_PIN B9  IOSTANDARD LVCMOS33} [get_ports {ETH_TXEN  }]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {ETH_TXD[0]}]
set_property -dict {PACKAGE_PIN A8  IOSTANDARD LVCMOS33} [get_ports {ETH_TXD[1]}]
set_property -dict {PACKAGE_PIN D5  IOSTANDARD LVCMOS33} [get_ports {ETH_REFCLK}]
set_property -dict {PACKAGE_PIN B8  IOSTANDARD LVCMOS33} [get_ports {ETH_INTN  }]

# Quad SPI Flash:
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports {QSPI_DQ[0]}]
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {QSPI_DQ[1]}]
set_property -dict {PACKAGE_PIN L14 IOSTANDARD LVCMOS33} [get_ports {QSPI_DQ[2]}]
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {QSPI_DQ[3]}]
set_property -dict {PACKAGE_PIN L13 IOSTANDARD LVCMOS33} [get_ports{ QSPI_CSN  }]
