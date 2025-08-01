using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MatchAPI.Models2;

[Index("PlayerId", "WeaponName", Name = "UQ__PlayerWe__9EA1A5EE4D4945EA", IsUnique = true)]
public partial class PlayerWeapon
{
    [Key]
    [Column("PlayerWeaponID")]
    public int PlayerWeaponId { get; set; }

    [Column("PlayerID")]
    [StringLength(50)]
    public string PlayerId { get; set; } = null!;

    [StringLength(50)]
    public string WeaponName { get; set; } = null!;

    public bool? IsOwned { get; set; }

    public DateTime? PurchaseDate { get; set; }

    [ForeignKey("PlayerId")]
    [InverseProperty("PlayerWeapons")]
    public virtual Player Player { get; set; } = null!;

    [ForeignKey("WeaponName")]
    [InverseProperty("PlayerWeapons")]
    public virtual Weapon WeaponNameNavigation { get; set; } = null!;
}
